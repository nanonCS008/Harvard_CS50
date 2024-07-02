using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class FallinHole : MonoBehaviour
{
    public GameObject whisperSource;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(transform.position.y< -2) // if players falls in hole load gameover scene
        {
            Destroy(whisperSource); //this line stops the whisper sound so that it does not overlap when we load the title scene
            SceneManager.LoadScene("Game Over");
        }
    }
}
