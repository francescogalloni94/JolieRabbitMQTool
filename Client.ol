include "console.iol"

execution{ concurrent }

type QSType: void{
	.e*: int
}

interface ArraySend {
  RequestResponse: sendArray(QSType)(QSType)
}

interface QuicksortInterface {
  RequestResponse: quicksort( QSType )( QSType )
}

inputPort ArrayIN {
	Location: "socket://localhost:8009"
	Protocol: sodep
	Interfaces: ArraySend
}

outputPort QuickSort {
	Location: "socket://localhost:8010"
	Protocol: sodep
	Interfaces: QuicksortInterface
}



main{


	sendArray(req)(sortedArray){
		println@Console("Array Sent to server")();
        quicksort@QuickSort(req)(sortedArray)


	}
	
}