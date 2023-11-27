using UnityEngine;

public class GOF : MonoBehaviour
{
    public Material planeMaterial;
    public ComputeShader computeShader;

    [Header("Game of Life Settings")]
    public Color cellColor = Color.white;

    private enum generationOptions { Random, FullTexture, RPentomino, Acorn, GosperGun }
    [SerializeField] private generationOptions generationType;

    private RenderTexture texture1, texture2;
    private int currentTextureIndex = 1;
    private int update1Kernel, update2Kernel;
    private float timeSinceLastUpdate;

    private const int THREAD_GROUP_SIZE = 32;

    void Start()
    {
        InitializeTextures();
        InitializeComputeShader();
        InitializeSimulation();
    }

    void Update()
    {
        UpdateSimulation();
    }

    void OnDestroy()
    {
        ReleaseTextures();
    }

    void InitializeTextures()
    {
        int textureWidth = 512, textureHeight = 512;
        texture1 = CreateRenderTexture(textureWidth, textureHeight);
        texture2 = CreateRenderTexture(textureWidth, textureHeight);
    }

    RenderTexture CreateRenderTexture(int width, int height)
    {
        RenderTexture texture = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32);
        texture.filterMode = FilterMode.Point;
        texture.enableRandomWrite = true;
        texture.Create();
        return texture;
    }

    void InitializeComputeShader()
    {
        update1Kernel = computeShader.FindKernel("CSInit");
        update2Kernel = computeShader.FindKernel("CSMain");
    }

    void InitializeSimulation()
    {
        SetGenerationType();
        ExecuteSeedKernel();
    }

    void UpdateSimulation()
    {
        int currentUpdateKernel = update2Kernel;

        // Pass the entire color as a float4 to the compute shader
        computeShader.SetVector("Color", new Vector4(cellColor.r, cellColor.g, cellColor.b, cellColor.a));

        ExecuteSimulationPhase(currentUpdateKernel);
        planeMaterial.SetTexture("_MainTex", texture1);
    }

    void ExecuteSimulationPhase(int kernelIndex)
    {
        int threadGroupsX = texture1.width / THREAD_GROUP_SIZE;
        int threadGroupsY = texture1.height / THREAD_GROUP_SIZE;
        computeShader.SetTexture(kernelIndex, "Result", (currentTextureIndex == 1) ? texture2 : texture1);
        computeShader.Dispatch(kernelIndex, threadGroupsX, threadGroupsY, 1);
        currentTextureIndex = 3 - currentTextureIndex;
    }

    void ExecuteSeedKernel()
    {
        int threadGroupsX = texture1.width / THREAD_GROUP_SIZE;
        int threadGroupsY = texture1.height / THREAD_GROUP_SIZE;
        computeShader.SetTexture(update1Kernel, "Result", texture1);
        computeShader.Dispatch(update1Kernel, threadGroupsX, threadGroupsY, 1);
    }

    void ReleaseTextures()
    {
        texture1.Release();
        texture2.Release();
    }

    void SetGenerationType()
    {
        int generationTypeValue = (int)generationType;
        computeShader.SetInt("GenerationType", generationTypeValue);
    }
}
