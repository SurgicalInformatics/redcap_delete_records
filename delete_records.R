# delete REDCap records using API/RCurl
# Riinu Pius 2021-01-20
library(tidyverse)
library(RCurl)

redcap_link = "https://..."
redcap_token = "1234"

# if want to delete all records in your DAG
# pull them using this code:
all_record_ids = postForm(uri=redcap_link,
                          token=redcap_token,
                          content='record',
                          format='csv',
                          type='flat',
                          csvDelimiter='',
                          'fields[0]'='record_id',
                          rawOrLabel='raw',
                          rawOrLabelHeaders='raw',
                          exportCheckboxLabel='false',
                          exportSurveyFields='false',
                          exportDataAccessGroups='true',
                          returnFormat='json') %>% 
  read_csv() %>% 
  select(record_id)

curl_call_list = all_record_ids %>% 
  rowid_to_column() %>% 
  mutate(line = paste0("'records[", rowid, "]'='", record_id, "'"))

# generate the RCurl call lines that list all record_ids
curl_call_list %>% 
  pull(line) %>% 
  paste0(collapse = ",\n") %>% 
  write(file = "all_records_formatted.txt")

# then copy-paste lines from all_records_formatted.txt to the postForm deletion call below:
# (replacing the records[0] - test lines)
# caution - while Export respects DAGs (so will only pull the record_ids for your DAG)
# the Delete action does not respect DAGs! So a user could delete records of a another DAG
# as long as they knew exactly what the record_ids are
# careful testing must be undertaken to make sure you're only deleting the records you intend to delete...
start_time = Sys.time()
postForm(
  uri=redcap_link,
  token=redcap_token,
  action='delete',
  content='record',
  # record_ids ----
  'records[0]'='test1',
  'records[1]'='test2'
  # record_ids done ----
)
end_time = Sys.time()
end_time - start_time

