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

