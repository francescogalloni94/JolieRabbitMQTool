include "runtime.iol"
include "console.iol"

execution{ concurrent }

type QSType: void{
	.e*: int
}

interface QuicksortInterface {
  RequestResponse: quicksort( QSType )( QSType )
}

inputPort SelfIn {
  Location: "local"
  Interfaces: QuicksortInterface
}

inputPort QuickSort {
  Location: "auto:ini:/locations/QuickSort:file:locations.ini"
  Protocol: sodep
  Interfaces: QuicksortInterface
}

outputPort SelfOut{
  Location: "local"
  Interfaces: QuicksortInterface
}

init { getLocalLocation@Runtime()( SelfOut.location ) }



main{


  quicksort( req )( res ){
  println@Console("sorting")();
  if( #req.e > 1 ){
   // 1. partition the request
   pivot = #req.e / 2;
   for ( i = 0, i < #req.e, i++ ) {
    if( i != pivot ) {
     if( req.e[ i ] <= req.e[ pivot ] ) {
      less.e[ #less.e ] << req.e[ i ]
     } else {
      greater.e[ #greater.e ] << req.e[ i ]
     }
    }
   };
  // 2. order the two partitions
  quicksort@SelfOut( less )( res );
  quicksort@SelfOut( greater )( greater );
  // merge the result
  res.e[ #res.e ] << req.e[ pivot ];
  for ( i=0, i<#greater.e, i++) {
    res.e[ #res.e ] << greater.e[ i ]
    }
  } else {
   res << req
   }
  }
}