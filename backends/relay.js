var util = require('util'),
    dgram = require('dgram'),
    hashring = require('hashring'),
    logger = require('../lib/logger');
var l;
var debug;
function RelayBackend(startupTime, config, emitter){
  var self = this;
  this.config = config.relay || [];
  this.sock = (config.relayProtocol == 'udp6') ?
        dgram.createSocket('udp6') :
        dgram.createSocket('udp4');

  // Map {host: 'localhost', port: 8200} to 'localhost:8200'
  var relays = this.config.map(function(h) { return h.host + ':' + h.port; });
  this.ring = new hashring(relays);
  // Attach DNS error handler
  this.sock.on('error', function (err) {
    if (debug) {
      l.log('Relay error: ' + err);
    } 
  });
  // attach
  emitter.on('packet', function(packet, rinfo) { self.process(packet, rinfo); });
};

RelayBackend.prototype.process = function(packet, rinfo) {
  var self = this;
  var streams = {};

  var packet_data = packet.toString();
  if (packet_data.indexOf("\n") > -1) {
    var metrics = packet_data.split("\n");
  } else {
    var metrics = [ packet_data ] ;
  }

  for (var midx in metrics) {
    // extract key (statsd bucket) from string
    var key = metrics[midx].split(':').shift(),
        hash = self.ring.get(key),
        target = hash.split(':'),
        host = target[0],
        port = target[1];

    var udp_packet = new Buffer(metrics[midx] + '\n');
    self.sock.send(udp_packet, 0, udp_packet.length, port, host, 
                  function(err, bytes) { if (err && debug) l.log(err); });
  }
};

exports.init = function(startupTime, config, events) {
  var instance = new RelayBackend(startupTime, config, events);
  l = new logger.Logger(config.log || {});
  debug = config.debug;
  return true;
};
