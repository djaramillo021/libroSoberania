// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Bonos is ERC20 {



    struct Bonista {
        uint256 ultimoIdBonoVotado; /*Identificador del ultimo bono aceptado por el bonista*/
        bool registrado; /*Bonista esta registrado para usar bono*/
    }
 
    struct DatosBono {
        uint256 idBono; /*Identificador del bono que una persona compra*/
        uint256 pagoPorBono; /*Cuanto paga el bono*/
        uint256 limiteBono; /*Cuando termina el bono*/
        string urlPdfBono; /*Url que contiene el contrato del bono*/
        uint256 maximoBonosPorPersona; /* Máxima cantidad de bonos que puede comprar una Persona*/
        uint256 minimoQuorum; /*Mínimo de quorum para aceptar una nueva propuesta */ 
    }

    struct PropuestaBono {
        bool puedeVotarse; 
        uint256 idBono;  /*Identificador del nuevo bono que una persona puede comprar que una persona compra*/
        uint256 pagoPorBono; /*Cuanto pagará el nuevo bono*/
        uint256 limiteBono;  /*Cuando terminará el nuevo bono*/
        string urlPdfBono;  /*Url que contiene el contrato del nuevo bono*/
        uint256 votosAfavor; /*Contador de votos a favor de la nueva propuesta*/
        uint256 maximoBonosPorPersona; /* Máxima cantidad de bonos que puede comprar una Persona*/
        uint256 minimoQuorum; /*Mínimo de quorum para aceptar una nueva propuesta */ 
    }

    mapping (address => Bonista) private usuariosPermitidos; /*Lista de tenedores permitido*/

    DatosBono private bonoActual; /*bono actual que usa el sistema actualmente, esta variable guarda datos con la estructura “DatosBono“*/

    PropuestaBono private nuevaPropuesta; /* Propuesta de un nuevo bono, esta variable guarda datos con la estructura “PropuestaBono“ */

    address private emisorDelBono; /*Identificador del emisor*/


    // eventos a registrar en la blockchain
    event Notificacion(uint blockTime,string noticia, address duenio );
    // eventos a registrar en la blockchain
    event Liquidar(uint blockTime, uint idBono, address duenio ,uint montoPagar);




    constructor (string memory name, string memory symbol)   ERC20 (name, symbol){
    }


/* Procedimiento que permite votar a cada tenedor una nueva  propuesta */ 
    function votarPropuesta() public  {
        Bonista storage bonistaRegistrado = usuariosPermitidos[msg.sender];

         /*Si el que ejecuta el procedimiento no es  bonista genera un error*/
        require(bonistaRegistrado.registrado==true, "Solo puede votar un bonista");
    
        /*Solo se pueden votar propuestas nueva nueva*/
        if(nuevaPropuesta.puedeVotarse){
            
             /*Un bonista solo puede votar una vez la propuesta*/
            if(bonistaRegistrado.ultimoIdBonoVotado != nuevaPropuesta.idBono){
                bonistaRegistrado.ultimoIdBonoVotado=nuevaPropuesta.idBono;
                nuevaPropuesta.votosAfavor=nuevaPropuesta.votosAfavor+1;
            }
            
           /*Si se alcanza el quorun se actualiza los datos el bono actual*/
            if(nuevaPropuesta.votosAfavor >=bonoActual.minimoQuorum){
                nuevaPropuesta.puedeVotarse=false;
                bonoActual.idBono = nuevaPropuesta.idBono;



               bonoActual.minimoQuorum= nuevaPropuesta.minimoQuorum;
                bonoActual.maximoBonosPorPersona=nuevaPropuesta.maximoBonosPorPersona;
                bonoActual.pagoPorBono = nuevaPropuesta.pagoPorBono;
                bonoActual.limiteBono = nuevaPropuesta.limiteBono;
                bonoActual.urlPdfBono = nuevaPropuesta.urlPdfBono;
            }
            
        }
        
    } 







/* Procedimiento que permite comprar un bono */             
function comprarBonoUsuarioYaRegistrado() public  {
        Bonista storage bonistaRegistrado = usuariosPermitidos[msg.sender];
       /*Si el que ejecuta el procedimiento no es  bonista genera un error*/
        require(bonistaRegistrado.registrado==true, "Solo puede votar un bonista");

       /* Valida si no ha superado el maximo de bonos permitido*/
        if(balanceOf(msg.sender)< bonoActual.maximoBonosPorPersona){
             /* Se genera un bono al bonista que ejecutó el procedimiento*/
            _mint(msg.sender, 1);
        }    
}



/* Procedimiento que emite un mensaje en la blockchain */             
function pubicarNoticar(string memory noticia) public   {
        
       /* Procedimiento que emite un mensaje en la blockchain */         
        emit Notificacion(block.timestamp,noticia,msg.sender );
} 


/* Procedimiento que genera el pago al bonista */    
function liquidarPago() public   {
      Bonista storage bonistaRegistrado = usuariosPermitidos[msg.sender];
      require(bonistaRegistrado.registrado==true, "Solo puede votar un bonista");
       /* Valida si no ha superado el maximo de bonos permitido*/

        /* Envia pago a otra blockchain */
        pagarSwapOtraBlockchain(msg.sender,balanceOf(msg.sender)*bonoActual.pagoPorBono);

        /* Emite evidencia del pago*/
        emit Liquidar(block.timestamp, bonoActual.idBono,msg.sender,balanceOf(msg.sender)*bonoActual.pagoPorBono);
    } 

    function pagarSwapOtraBlockchain(address duenio,uint monto) public   {
        /* Implementar*/
    } 


}
