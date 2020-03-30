using UnityEngine;

public class DeferredShading : MonoBehaviour
{
    private static RenderTexture[] GBufferRTs;
    private RenderBuffer[] ColorBuffers;
    private RenderBuffer DepthBuffer;
    private Camera MainCamera;
    private Camera RenderCamera;
    private Shader GBufferShader;
    private Material SceneMaterial;

    void Start()
    {
        ReformCameras();
        CreateBuffers();
        GBufferShader = Shader.Find("LearningNotes/1_DrawGBufferShader");
        SceneMaterial = new Material(Shader.Find("LearningNotes/1_DrawSceneShader"));
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Shader.SetGlobalTexture("_MainTex", GBufferRTs[0]);
        Shader.SetGlobalTexture("_NormalAndDepthTex", GBufferRTs[1]);
        Shader.SetGlobalTexture("_PositionTex", GBufferRTs[2]);

        source = GBufferRTs[0];

        Graphics.Blit(source, destination, SceneMaterial);
    }

    void OnPostRender()
    {
        RenderCamera.SetTargetBuffers(ColorBuffers, DepthBuffer);
        RenderCamera.RenderWithShader(GBufferShader, "");
    }

    void OnGUI()
    {
        Vector2 size = new Vector2(240, 120);
        float margin = 20;
        GUI.DrawTexture(new Rect(margin, Screen.height - (size.y + margin), size.x, size.y), GBufferRTs[0], ScaleMode.StretchToFill, false, 1);
        GUI.DrawTexture(new Rect(margin + margin + size.x, Screen.height - (size.y + margin), size.x, size.y), GBufferRTs[1], ScaleMode.StretchToFill, false, 1);
        GUI.DrawTexture(new Rect(margin + margin + margin + size.x + size.x, Screen.height - (size.y + margin), size.x, size.y), GBufferRTs[2], ScaleMode.StretchToFill, false, 1);
    }

    private void OnDestroy()
    {
        Destroy(RenderCamera.gameObject);
    }

    void ReformCameras()
    {
        MainCamera = GetComponent<Camera>();
        MainCamera.renderingPath = RenderingPath.VertexLit;
        MainCamera.cullingMask = 0;
        MainCamera.clearFlags = CameraClearFlags.Depth;
        MainCamera.backgroundColor = Color.black;

        RenderCamera = new GameObject("RenderCamera").AddComponent<Camera>();
        RenderCamera.depthTextureMode |= DepthTextureMode.Depth;
        RenderCamera.enabled = false;
        RenderCamera.transform.parent = gameObject.transform;
        RenderCamera.transform.localPosition = Vector3.zero;
        RenderCamera.transform.localRotation = Quaternion.identity;
        RenderCamera.renderingPath = RenderingPath.VertexLit;
        RenderCamera.clearFlags = CameraClearFlags.SolidColor;
        RenderCamera.farClipPlane = MainCamera.farClipPlane;
        RenderCamera.fieldOfView = MainCamera.fieldOfView;
    }

    void CreateBuffers()
    {
        GBufferRTs = new RenderTexture[]
        {
            RenderTexture.GetTemporary(Screen.width, Screen.height, 32, RenderTextureFormat.Default),
            RenderTexture.GetTemporary(Screen.width, Screen.height, 32, RenderTextureFormat.Default),
            RenderTexture.GetTemporary(Screen.width, Screen.height, 32, RenderTextureFormat.DefaultHDR)
        };

        ColorBuffers = new RenderBuffer[]
        {
            GBufferRTs[0].colorBuffer,
            GBufferRTs[1].colorBuffer,
            GBufferRTs[2].colorBuffer
        };

        DepthBuffer = GBufferRTs[1].depthBuffer;
    }
}
