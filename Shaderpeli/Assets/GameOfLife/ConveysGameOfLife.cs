using UnityEngine;
using System.Collections;

public class ConwaysGameOfLife : MonoBehaviour
{
    public enum InitializationMode
{
    Random,
    FullTexture,
    RPentomino,
    Acorn,
    GosperGun
}


    public InitializationMode initializationMode = InitializationMode.Random;
    public Material gameOfLifeMaterial;
    public Color livingCellColor;
    public float updateDelay = 0.5f;

    public ComputeShader gameOfLifeComputeShader;

    private RenderTexture texture1;
    private RenderTexture texture2;
    private bool isTexture1Active = true;

    private void Start()
    {
        InitializeTextures();
        StartCoroutine(UpdateGameOfLife());
    }

    private void InitializeTextures()
{
    gameOfLifeComputeShader.SetVector("LivingCellColor", livingCellColor);

    texture1 = CreateRenderTexture();
    texture2 = CreateRenderTexture();

    if (initializationMode == InitializationMode.Random)
    {
        // Set random values for texture1
        SetRandomTextureValues(texture1);

        // Set random values for texture2
        SetRandomTextureValues(texture2);
    }
    else if (initializationMode == InitializationMode.FullTexture)
    {
        // Initialize full texture based on logic
        InitializeFullTexture(texture1);
        InitializeFullTexture(texture2);
    }
    else if (initializationMode == InitializationMode.RPentomino)
    {
        // Initialize texture with RPentomino pattern
        InitializeRPentomino(texture1);
        InitializeRPentomino(texture2);
    }
    else if (initializationMode == InitializationMode.Acorn)
    {
        // Initialize texture with RPentomino pattern
        InitializeAcorn(texture1);
        InitializeAcorn(texture2);
    }
    else if (initializationMode == InitializationMode.GosperGun)
    {
        // Initialize texture with RPentomino pattern
        InitializeGun(texture1);
        InitializeGun(texture2);
    }
}

    private void InitializeFullTexture(RenderTexture texture)
    {
    int kernel = gameOfLifeComputeShader.FindKernel("InitFullTexture");

    // Make sure the property name matches what is defined in the shader
    gameOfLifeComputeShader.SetTexture(kernel, "OutputTexture", texture);
    gameOfLifeComputeShader.Dispatch(kernel, 512 / 8, 512 / 8, 1);
    }

    private void InitializeRPentomino(RenderTexture texture)
    {
    int kernel = gameOfLifeComputeShader.FindKernel("InitRPentomino");

    // Make sure the property name matches what is defined in the shader
    gameOfLifeComputeShader.SetTexture(kernel, "OutputTexture", texture);
    gameOfLifeComputeShader.Dispatch(kernel, 512 / 8, 512 / 8, 1);
    }

    private void InitializeAcorn(RenderTexture texture)
    {
    int kernel = gameOfLifeComputeShader.FindKernel("InitAcorn");

    // Make sure the property name matches what is defined in the shader
    gameOfLifeComputeShader.SetTexture(kernel, "OutputTexture", texture);
    gameOfLifeComputeShader.Dispatch(kernel, 512 / 8, 512 / 8, 1);
    }

    private void InitializeGun(RenderTexture texture)
    {
    int kernel = gameOfLifeComputeShader.FindKernel("InitGun");

    // Make sure the property name matches what is defined in the shader
    gameOfLifeComputeShader.SetTexture(kernel, "OutputTexture", texture);
    gameOfLifeComputeShader.Dispatch(kernel, 512 / 8, 512 / 8, 1);
    }



    private RenderTexture CreateRenderTexture()
    {
        RenderTexture texture = new RenderTexture(512, 512, 0);
        texture.filterMode = FilterMode.Point;
        texture.wrapMode = TextureWrapMode.Repeat;
        texture.enableRandomWrite = true;
        texture.Create();
        return texture;
    }

    private void SetRandomTextureValues(RenderTexture texture)
    {
        int width = texture.width;
        int height = texture.height;

        Texture2D randomTexture = new Texture2D(width, height, TextureFormat.RGBA32, false);
        Color[] randomColors = new Color[width * height];

        // Set random values for each pixel
        for (int i = 0; i < randomColors.Length; i++)
        {
            if (Random.value < 0.5f)
            {
                randomColors[i] = Color.black;
            }
            else
            {
                randomColors[i] = livingCellColor;
            }
        }

        randomTexture.SetPixels(randomColors);
        randomTexture.Apply();

        // Copy the random texture to the render texture
        Graphics.Blit(randomTexture, texture);
        Destroy(randomTexture); // Cleanup temporary Texture2D object
    }

    private IEnumerator UpdateGameOfLife()
    {
        while (true)
        {
            
            ApplyGameOfLifeRules();

            isTexture1Active = !isTexture1Active;
            gameOfLifeMaterial.SetTexture("_MainTex", isTexture1Active ? texture1 : texture2);

            yield return new WaitForSeconds(updateDelay);
        }
    }

    private void ApplyGameOfLifeRules()
    {
        int kernel = gameOfLifeComputeShader.FindKernel("CSMain");
        gameOfLifeComputeShader.SetTexture(kernel, "InputTexture", isTexture1Active ? texture1 : texture2);
        gameOfLifeComputeShader.SetTexture(kernel, "OutputTexture", isTexture1Active ? texture2 : texture1);
        gameOfLifeComputeShader.Dispatch(kernel, 512 / 8, 512 / 8, 1);
    }
}
