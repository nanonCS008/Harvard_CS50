using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CollisionScript : MonoBehaviour
{
    public Text text;
    // Start is called before the first frame update
    void Start()
    {
        // start text off as completely transparent black
		text.gameObject.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other) {
        text.gameObject.SetActive(true);
    }
}
