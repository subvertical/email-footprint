'use strict';

var AWS = require('aws-sdk');

var AWS_REGION       = process.env.AWS_REGION;
var EVENTS_TABLE     = process.env.EVENTS_TABLE;
var CAMPAIGNS_TABLE  = process.env.CAMPAIGNS_TABLE;
var EVENTS_QUEUE_URL = process.env.EVENTS_QUEUE_URL;

var sqs       = new AWS.SQS({ region: AWS_REGION });
var docClient = new AWS.DynamoDB.DocumentClient();
var dynamoDB  = new AWS.DynamoDB();

function guid() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
}

function deleteMessage(receiptHandle, cb) {
  sqs.deleteMessage({
    ReceiptHandle: receiptHandle,
    QueueUrl: EVENTS_QUEUE_URL
  }, cb);
}

function work(message, cb) {
  console.log(message);

  message = JSON.parse(JSON.parse(message)['Message']);
  console.log('From SQS', message);

  const eventType  = message['eventType'];
  const recipient  = message['mail']['destination'][0];
  const campaignId = message['mail']['tags']['campaign_id'][0];

  var eventsTableParams = {
    TableName: EVENTS_TABLE,
    Item: {
      'UUID':       guid(),
      'EventType':  eventType,
      'Recipient':  recipient,
      'CampaignId': campaignId,
      'Timestamp':  (new Date()).toISOString()
    }
  }

  console.log('EventsTable Update.');
  docClient.put(eventsTableParams, function (err, data) {
    if (err) console.log(err);
    else console.log('DynamoDB write succeeded with: ', data);
  });

  var campaignsTableParams = {
    TableName: CAMPAIGNS_TABLE,
    Key: {'CampaignId': {'S': campaignId}},
    ExpressionAttributeNames: {'#ET': eventType},
    ExpressionAttributeValues: {':et_value': {'N': '1'}},
    UpdateExpression: 'ADD #ET :et_value',
  };

  console.log('CampaignsTable Update');
  dynamoDB.updateItem(campaignsTableParams, function (err, data) {
    if (err) console.log(err);
    else console.log('Camps DynamoDB write succeeded with: ', data);
  });

  console.log('From SQS', message);
  cb();
}

exports.handler = function(event, context, callback) {
  work(event.Body, function(err) {
    if (err) {
      callback(err);
    } else {
      deleteMessage(event.ReceiptHandle, callback);
    }
  });
};
