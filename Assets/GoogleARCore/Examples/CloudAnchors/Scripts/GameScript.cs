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

    //botao inicial de entrar numa cena
    public void entrarClick()
    {
        for(int i = 0; i < this.telas.Length; i++)
        {
            this.telas[1].enabled = false;
            // exibe apenas a tela 1
            if (i != 1)
            {
                this.telas[i].enabled = false;
            }
        }

    }

    public void escolherCenaVoltarClick()
    {
        this.telas[state].enabled = false;
        this.state += 1;
        this.telas[state].enabled = true;
    }
	
	// Update is called once per frame
	void Update () {
		
	}


}
