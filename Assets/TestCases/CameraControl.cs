using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    public float _moveSpeed = 10.0f;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.Q))
            transform.Translate(new Vector3(0.0f, _moveSpeed * Time.deltaTime, 0.0f));
        if (Input.GetKey(KeyCode.E))
            transform.Translate(new Vector3(0.0f, -_moveSpeed * Time.deltaTime, 0.0f));
        if (Input.GetKey(KeyCode.A))
            transform.Translate(new Vector3(-_moveSpeed * Time.deltaTime, 0.0f, 0.0f));
        if (Input.GetKey(KeyCode.D))
            transform.Translate(new Vector3(_moveSpeed * Time.deltaTime, 0.0f, 0.0f));
        if (Input.GetKey(KeyCode.W))
            transform.Translate(new Vector3(0.0f, 0.0f, _moveSpeed * Time.deltaTime));
        if (Input.GetKey(KeyCode.S))
            transform.Translate(new Vector3(0.0f, 0.0f, -_moveSpeed * Time.deltaTime));
    }
}
