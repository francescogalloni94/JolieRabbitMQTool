
include "exec.iol"
include "file.iol"
include "console.iol"
include "string_utils.iol"
include "database.iol"
include "time.iol"
include "InterfaceAPI.iol"
include "ini_utils.iol"


outputPort DockerIn {
	Location: "socket://localhost:8008"
	Protocol: sodep
	Interfaces: InterfaceAPI
}


main
{
	iniRequest="DockerAutomatization.ini";
    parseIniFile@IniUtils(iniRequest)(iniResponse);
    
    println@Console("pulling rabbitmq ...")();

    IMAGE_NAME = "rabbitmq";
    with( rq ) {
      .fromImage = IMAGE_NAME;
      .tag = "latest";
      .repo = "-"
     };

    imageCreate@DockerIn( rq )( response );
    println@Console("pull complete")();
    undef( rq );
    rqCnt.name = "rabbitexposecnt";
		rqCnt.Image = "rabbitmq:latest";
		rqCnt.ExposedPorts.("5672/tcp") = obj.("{}");
		createContainer@DockerIn( rqCnt )( serverResponse );
		rabbitId.id=serverResponse.Id;

    undef(rqCnt);
	startContainer@DockerIn( rabbitId )( response );
    

    info.filters.id =rabbitId.id;
    containers@DockerIn( info )( container_info );
    serverqueue_host = container_info.container[ 0 ].NetworkSettings.Networks.bridge.IPAddress;
    undef( crq );

    file.filename ="RabbitMQTool/dependencies.iol";
	file.content = "constants {\n"
                   +"JDEP_RABBITMQ_LOCATION =\""+serverqueue_host+"\"\n"
				   +"}\n";						

	writeFile@File( file )();
	undef( file );


    name=new;
	mkdir@File( name )();
	rabbitfolder=name+"/RabbitMQTool";
	libfolder=name+"/lib";
	mkdir@File(rabbitfolder)();
    mkdir@File(libfolder)();
    readFile.filename=iniResponse.automatizationParameter.serverFile;
    readFile@File(readFile)(file);
    fileRequest.content=file;
    fileRequest.filename=name+"/Server.ol";
    writeFile@File(fileRequest)();
	copyDir@File({.to=rabbitfolder, .from="RabbitMQTool"})();
	copyDir@File({.to=libfolder, .from="lib"})();
	undef( file );
	file.filename = name + "/Dockerfile";
	file.content = "FROM jolielang/jolie-docker-deployer\n"
	                +"COPY " + name + "/Server.ol main.ol\n"
	                +"COPY "+name+"/RabbitMQTool RabbitMQTool\n"
	                +"COPY "+name+"/lib lib\n";

	writeFile@File( file )();
	undef( file );
	
	ex_rq = "tar";
	ex_rq.args[ 0 ] = "-cvf";
	ex_rq.args[ 1 ] =name+".tar";
	ex_rq.args[ 2 ] =name;
	ex_rq.waitFor = 1;
	exec@Exec( ex_rq )();

	deleteDir@File( name )();


	file.filename =name+".tar";
	file.format = "binary";
	readFile@File( file )( rq.file );
	rq.t = "serverqueue:latest";
	rq.dockerfile =name+"/Dockerfile";
	build@DockerIn( rq )( response );
	
	undef( rq );
	undef( ex_rq );
    undef( name );





	name=new;
	rabbitfolder=name+"/RabbitMQTool";
	libfolder=name+"/lib";
	mkdir@File( name )();
	mkdir@File(rabbitfolder)();
	mkdir@File(libfolder)();
	undef( readFile );
	readFile.filename=iniResponse.automatizationParameter.clientFile;
    readFile@File(readFile)(file);
    undef( fileRequest );
    fileRequest.content=file;
    fileRequest.filename=name+"/Client.ol";
    writeFile@File(fileRequest)();
    undef( file );
	copyDir@File({.to=rabbitfolder, .from="RabbitMQTool"})();
	copyDir@File({.to=libfolder, .from="lib"})();
	file.filename = name + "/Dockerfile";
	file.content = "FROM jolielang/jolie-docker-deployer\n"
	                +"COPY " + name + "/Client.ol main.ol\n"
	                +"COPY " + name+"/RabbitMQTool RabbitMQTool\n"
	                +"COPY "+name+"/lib lib\n";
	                
	               
	writeFile@File( file )();
	undef( file );
	ex_rq = "tar";
	ex_rq.args[ 0 ] = "-cvf";
	ex_rq.args[ 1 ] =name+".tar";
	ex_rq.args[ 2 ] =name;
	ex_rq.waitFor = 1;
	exec@Exec( ex_rq )();
	deleteDir@File( name )();


	file.filename =name+".tar";
	file.format = "binary";
	readFile@File( file )( rq.file );
	rq.t = "clientqueue:latest";
	rq.dockerfile =name+"/Dockerfile";
	build@DockerIn( rq )( response );
  
    numberOfservers=iniResponse.automatizationParameter.numberOfServers;
    for ( i=0,i<numberOfservers,i++) {
      
	    rqCnt.name = "serverqueuecnt-"+i;
		rqCnt.Image = "serverqueue:latest";
		rqCnt.Env[0]="JDEP_RABBITMQ_LOCATION="+serverqueue_host;
		createContainer@DockerIn( rqCnt )( serverResponse );
		serverqueuecnt.id=serverResponse.Id;
		crq.id=serverqueuecnt.id;
	    startContainer@DockerIn( crq )( response );
        undef(rqCnt);
        undef( crq)


     };

   numberOfClients=iniResponse.automatizationParameter.numberOfClients;

   for (i=0,i<numberOfClients,i++) {
      
    rqCnt.name="clientqueuecnt-"i;
    rqCnt.Image="clientqueue:latest";
    rqCnt.Env[0] = "JDEP_RABBITMQ_LOCATION="+serverqueue_host;
    createContainer@DockerIn( rqCnt )( clientResponse );
    clientqueuecnt.id=clientResponse.Id;
    crq.id=clientqueuecnt.id;
	startContainer@DockerIn( crq )( response );
	undef(rqCnt);
    undef( crq)
   }

    
	










}