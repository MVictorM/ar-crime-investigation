using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameScript : MonoBehaviour {

    int state = 0;

    public Canvas[] telas = new Canvas[5]; 

	// Use this for initialization
	void Start () {
        this.telas[0].enabled = true;
	}

    public void entrarClick()
    {
        this.telas[state].enabled = false;
        this.state += 1;
        this.telas[state].enabled = true;

    }
	
	// Update is called once per frame
	void Update () {
		
	}


}
