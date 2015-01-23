#!/usr/bin/node
var fs = require('fs');
var util = require('util');
var http = require('http');
var https = require('https');

var apiEntry = {}
var nodes = {}


process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

function parseJsonFromFile(err, data) {
	if(err) {
		util.error(err);
		process.exit(1);
	}
	try{
		apiEntry = JSON.parse(data);
	} catch (e) {
		util.error("Could not parse JSON");
		util.error(e);
		process.exit(2);
	}
}

function getNodesInformation(){
	https.get("https://map.md.freifunk.net/nodes.json", function(res) {
		data = "";
		res.on('data', function(d) {
			data = data + d;
		});
		res.on('end',function() {
			nodes = JSON.parse(data);
			updateNodeNumber(nodes);

		});
	});
}

function updateNodeNumber(nodes){
	var routers = nodes.nodes.filter(function(node) {
		return !node.flags.client & !node.flags.gateway & node.flags.online;
	});
	apiEntry.state.nodes = routers.length;
	util.puts(util.inspect(apiEntry));
}


fs.readFile("ffmd.json", parseJsonFromFile);
getNodesInformation();

