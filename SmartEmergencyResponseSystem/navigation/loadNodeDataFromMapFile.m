function [nodeTable, transitGraph, deploymentMgr] = loadNodeDataFromMapFile(filename)
    nodeTable = NodeTable;
    transitGraph = GroundTransportationGraph;
    deploymentMgr = DeploymentManager;

    fid = fopen(filename);
    garbageLine1 = fgets(fid);
    garbageLine2 = fgets(fid);

    numNodes = str2double(regexp(fgets(fid),'NN=(\d+)','tokens','once'));
    newNodeLats = zeros(numNodes,1);   % preallocate for speed
    newNodeLons = zeros(numNodes,1);
    newNodeWeights = zeros(numNodes,1);
    newNodePops = zeros(numNodes,1);
    newNodeDeployments = false(numNodes,1);
    for ii = 1:numNodes
        raw = fgets(fid);
        newNodeLats(ii) = str2double(regexp(raw,'Lat=([+-]?\d*\.\d*)','tokens','once'));
        newNodeLons(ii) = str2double(regexp(raw,'Lon=([+-]?\d*\.\d*)','tokens','once'));
        newNodeWeights(ii) = str2double(regexp(raw,'C2=([+-]?\d*\.\d*)','tokens','once'));
        newNodePops(ii) = str2double(regexp(raw,'C3=([+-]?\d*\.\d*)','tokens','once'));
        newNodeDeployments(ii) = str2double(regexp(raw,'DN=([+-]?\d*)','tokens','once'));
    end
    nodeTable.addNodes(newNodeLats,newNodeLons,newNodeWeights,newNodePops);
    deploymentMgr.addNodes(newNodeDeployments);

    numArcs = str2double(regexp(fgets(fid),'NA=(\d+)','tokens','once'));
    newArcTails = zeros(numArcs,1);     % preallocate for speed
    newArcHeads = zeros(numArcs,1);
    newArcWeights = zeros(numArcs,1);
    for ii = 1:numArcs
        raw = fgets(fid);
        newArcTails(ii) = str2double(regexp(raw,'N1=([+-]?\d*)','tokens','once'));
        newArcHeads(ii) = str2double(regexp(raw,'N2=([+-]?\d*)','tokens','once'));
        newArcWeights(ii) = str2double(regexp(raw,'L=([+-]?\d*\.\d*)','tokens','once'));
    end
    transitGraph.addArcs(newArcTails,newArcHeads,newArcWeights);
    fclose(fid);
end