include "console.iol"
include "math.iol"


type QSType: void{
	.e*: int
}


interface ArraySend {
  RequestResponse: sendArray(QSType)(QSType)
}

outputPort ArrayOut {
	Location: "socket://localhost:8009"
	Protocol: sodep
	Interfaces: ArraySend
}

main
{
  
   /*array.e[0]=20;
   array.e[1]=15;
   array.e[2]=69;
   array.e[3]=17;
   array.e[4]=320;
   array.e[5]=2;
   array.e[6]=13;
   array.e[7]=28;*/
   for(i=0,i<10000,i++){
      random@Math()(random);
      array.e[i]=int(random*100)
   };
   println@Console("Array sent to Array dispatcher")();
   sendArray@ArrayOut(array)(response);
   println@Console("Received sorted array")()
   /*for ( i=0,i<#response.e,i++) {
   	println@Console(response.e[i]+"\n")()
     
   }*/



}