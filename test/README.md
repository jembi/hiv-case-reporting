# Running test transactions

You will need to download [Postman](https://www.postman.com/downloads/) then import the JSON collection in this directory. There will be a folder per report, select the 'report bundle' request for the report you want to test and hit send. By default the collection will point to `localhost`.

## Pointing the collection at staging or QA

You will need to change the variable for the host port to point to staging or QA instead:

1. click the three dots next to CDR
1. click Edit
1. click Variables
1. change 'openhimHost' to the staging IP under current value
1. click Update

## Adjusting dynamic variables in the request

There are some variables in the requests which get randomised when you hit send. To adjust these or add more see where they are setup by:

1. click the three dots next to CDR
1. click Edit
1. click Pre-request Scripts
1. Adjust as needed
1. click Update
