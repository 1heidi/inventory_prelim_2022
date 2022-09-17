## GBC Inventory Preliminary Exploration - Summer 2022

#### Evaluating preliminary NER prediction results

* work-in-progress - currently: calculated best predicted names (common and full) and created a 10% sample for manual review and evaluation; evaluation completed (file name ner_predictions_sample_hji_2022-07-01_V4.csv)
  * 97.1% at least 1 common name, mean probability of highest = 0.9681
  * 34.7% at least 1 full name, mean probability of highest = 0.8732

* precision via manual review 
  * classification 439 correct/(439 correct + 29 incorrect) = 0.9380
  * common name 425 correct/(425 correct + 10 incorrect + 22 partial) = 0.9299
  * full name 97 correct/(97 correct + 7 incorrect + 53 partial) = 0.6178

#### Extracting County from Affiliations in ePMC Records

* work-in-progress - currently: testing with countrycode/maps R packages and internal ePMC algorithm

#### Extracting re3data and FAIRSharing DB Records

* work-in-progress - currently: have db records from both, comparing to preliminary NER results above
** NOTE: FAIRsharing data not pushed to public b/c of licencing

#### Testing http status of extracted urls and Wayback Machine archiving 

* work-in-progress - currently: using 10% ner prediction sample for testing; completed one run of 5x attempts at http status and wayback machine url retrieval 
  * 323/467 (69.1%) return 200 (108 failed by timeout, etc & 36 returned unsuccessful codes)
  * 390/467 (83.5%) return a wayback machine url
  * 37/467 (7.9%) have no successful url (either 200 extracted or wayback machine url)
  
#### Comparsion of results between original query (old) and optimized query (new) 
* work-in-progress - compared PMIDs returned from both to make sure the new query is performing better (and not wildly different)
  * see script - STEP_N_Query_Comparison.R
  * old - returns 22169
  * new - returns 21414, filters much better for clinical trials, plus the wileyonline, zenodo, etc. that were returned in the old query. Does not returning some that did return via the old and seem like should return via the new query as well (e.g.24876870, 34644572, 21804097, 27899610 - I am checking with EPMC on this); is returning some new too ...
    * total unique between both new and old = 22958, 20625 in common between both, 789 unique to new (now returned when did not before), 1544 unique to old query (no longer returning with new query)
     * see all_unmatched_query_check_2022-09-17.csv those that are not in common
  * there are 195 records in the manually curated training dataset that are not part of the new query results
      * see manually_classified_not_in_new_query_2022-09-17.csv
      
#### Comparsion of results between June ner predictions and September
* work-in-progress - checking old predictions not found this time to see if junky or just not in the query to begin
  * see script - STEP_N_Compare_NER_Predictions.R
  * only 188 previously predicted in June are not in the new query returns, for the others that were available, lots just failed to return a prediction this time but worked okay before (decent probabilities and spot checking text, many or even most look right) - something wonky?
  * see compare_ner_results_2022-09-17.csv


