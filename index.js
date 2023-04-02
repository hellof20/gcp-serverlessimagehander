'use strict';

const {Storage} = require("@google-cloud/storage");
const storage = new Storage();
const sharp = require('sharp');

exports.serverlessimagehandler = (req, res) => {
  var resize = req.query.resize
  var bucket = req.query.bucket
  var image = req.query.image
  console.log(resize)
  console.log(bucket)
  console.log(image)
  let file = storage.bucket(bucket).file(image);
  file.getMetadata().then(function(data) {
    const metadata = data[0];
    const contentType = metadata.contentType
    let readStream = file.createReadStream();
    res.setHeader("content-type", contentType);
    var transformer = sharp().resize(JSON.parse(resize))
    readStream.pipe(transformer).pipe(res)
  });
};
