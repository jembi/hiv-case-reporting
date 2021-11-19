'use strict'

const fs = require('fs')
const https = require('https')
const path = require('path')

const OPENHIM_API_HOSTNAME = process.env.OPENHIM_API_HOSTNAME || 'openhim-core'
const OPENHIM_API_TOKEN =
  process.env.OPENHIM_API_Token|| 'test'
const OPENHIM_API_PORT = process.env.OPENHIM_API_PORT || 5000
const OPENHIM_API_PROTOCOL =
  process.env.OPENHIM_API_PROTOCOL || 'https'

const jsonData = JSON.parse(
  fs.readFileSync(path.resolve(__dirname, 'hiv-report.json'))
)

const data = JSON.stringify(jsonData)

const options = {
  protocol: OPENHIM_API_PROTOCOL,
  hostname: OPENHIM_API_HOSTNAME,
  port: OPENHIM_API_PORT,
  path: '/fhir',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length,
    Authorization: `Custom ${OPENHIM_API_TOKEN}`
  }
}

const req = https.request(options, res => {
  if (res.statusCode == 401) {
    throw new Error(`Incorrect OpenHIM credentials`)
  }

  if (res.statusCode != 200) {
    throw new Error(`Failed to send hiv case report: ${res.statusCode}`)
  }

  console.log('Successfully sent hiv case report to the OpenHIM')
})

req.on('error', error => {
  console.error('Failed to send hiv case report: ', error)
})

req.write(data)
req.end()
