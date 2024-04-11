use "Project"

//Database Implementations:

//For owid, we generate a filtered collection owidcountries with only legitimate countries, for use in qn 1 to 3.
//For this we added a attribute "length" which is the length of the iso_code, and match it to 3 (which we interpreted to represent valid countries).
//We also replaced the attribute "year" with integer values to save the need to do it for every question.
db.owid.aggregate([
    {$addFields:  {length: {$strLenCP: "$iso_code"},year:{$toInt: "$year"}}},
    {$match: {length: 3}},
    {$out: "owidcountries"}
    ])
db.energyimport.aggregate([
    {$project: {year: 1, energy_products: 1, sub_products: 1, value_ktoe: "$import_ktoe"}}
    ])
//For energyimport and energyexport, we merged both collections into a new collection - "sg_energy"
//Both of these initial collections are likely to be analysed together as they contain the same fields, differing only in whether the values are for export or import
//Thus, it is inefficient to analyse them together as separate collections ($lookup), so we merged them into one new collection
db.energyexport.updateMany({}, [{$set: {"match_id": {$concat: ["$year","_", "$sub_products"]}}}])  //create new field "match_id" from "year" & "sub_product" 
db.energyimport.updateMany({}, [{$set: {"match_id": {$concat: ["$year","_", "$sub_products"]}}}],) //"match_id" serves as the unique 'identifier' to merge correct documents together ($lookup)
db.energyimport.updateMany({}, {$rename: {value_ktoe: "import_ktoe"}})                             //import "value_ktoe" renamed to "import_ktoe"

db.energyimport.aggregate([
    {$lookup: {from: "energyexport2", localField: "match_id", foreignField: "match_id", as: "energyexport"}},
    {$addFields: {export_ktoe: "$energyexport.value_ktoe"}},                                      //export "value_ktoe" addes as new field "export_ktoe"
    {$unset: ["energyexport", "match_id"]},                                                       //removing unique identifier for $lookup and irrelavant array
    {$unwind: {"path": "$export_ktoe", "preserveNullAndEmptyArrays": true}},                      //unwind export_ktoe array such that it becomes a field, keeping null arrays
    {$project: {year: {$toInt: "$year"}, energy_products: 1, sub_products: 1,                     //correct datatypes (string to int), replacing empty or error values with null
    import_ktoe: {$convert:{input: "$import_ktoe", to: 1, onError: null, onNull: null}},  export_ktoe: {$convert:{input: "$export_ktoe", to: 1, onError: null, onNull: null}}}},
    {$out: "sg_energy"}                                                                           //output as new collection "sg_energy"
    ])

//For hec, we perform data cleaning by removing Region:Overall, month:Annual and kwh_per_acc:s\r (interpreted as erroneous inputs).
//We also converted the entries to the right datatypes to save the need to do it for every question.
db.hec.aggregate([                                                                                                      
    {$match: {"$and": [{Region: {$ne: "Overall"}}, {month: {$ne: "Annual"}}, {kwh_per_acc: {$ne: "s\r"}}]}},
    {$project: {year: {$toInt: "$year"}, month: {$toInt: "$month"}, Region: 1, kwh_per_acc: {$convert: {input: {$substr: ["$kwh_per_acc", 0,       // convert year to Int, trim kwh_per_acc to exclude extra "\r" char at end
                         {$subtract: [{$strLenCP: "$kwh_per_acc"}, 1]}]}, to: 1, onError: null, onNull: null}}}},
    {$out: "filtered_hec"}                                                                                              
    ])  

// Question 1 ================================================================================================================================================
// Assumption: Countries refer to distinctly governed geographical territories (with 3-lettered iso_codes)

db.owidcountries.aggregate([
    {$group: {_id: {country: "$iso_code"}}},
    {$count:"Number of countries captured in dataset"}
    ])

// Question 2 ================================================================================================================================================
// Finding the number of documents a country need to have for it to have a record in every year in the period
db.owidcountries.aggregate([
    {$group:{_id:{},minyear:{$min:"$year"},maxyear:{$max:"$year"}}},
    {$project:{_id:0,minyear:1,maxyear:1,count:{$add:[{$subtract:["$maxyear","$minyear"]},1]}}}
    ])

db.owidcountries.aggregate([
    {$group:{_id:{country:"$country",year:"$year"}}},   // group by country and year to remove the possibility of a country having duplicate entries for the same year
    {$group:{_id:"$_id.country",count:{$sum:1}}},       // group by country and match the count (of distinct years) to 122 (from previous query)    
    {$match:{count:122}},
    {$sort:{_id:1}}
    ])
    
// Question 3 ================================================================================================================================================

// The possible sources of energy are: fossil,biofuel,coal,gas,hydro,low_carbon,nuclear,oil,other_renewables,renewables,solar,wind
// Fossil includes coal,gas,oil
// Low carbon includes renewables and nuclear
// Renewables include other_renewables,biofuel,hydro,solar,wind
// So, "new sources of energy" includes biofuel,hydro,nuclear,other_renewables,solar,wind (removed collective categories)

db.owidcountries.aggregate([
    {$match:{"$and": [{country: "Singapore"}, {fossil_share_energy: {$nin: ["100.0",""]}}]}},   //match country:"Singapore" and fossil_share_energy:not "" and not "100.0"
    {$project:{_id:0,country:1,year:1,fossil_share_energy:1,                                    //project alternate sources only if they are not "" or "0.0"
    biofuel_share_energy:{$cond:[{$in:["$biofuel_share_energy",["","0.0"]]},"$$REMOVE","$biofuel_share_energy"]},
    hydro_share_energy:{$cond:[{$in:["$hydro_share_energy",["","0.0"]]},"$$REMOVE","$hydro_share_energy"]},
    nuclear_share_energy:{$cond:[{$in:["$nuclear_share_energy",["","0.0"]]},"$$REMOVE","$nuclear_share_energy"]},
    other_renewables_share_energy:{$cond:[{$in:["$other_renewables_share_energy",["","0.0"]]},"$$REMOVE","$other_renewables_share_energy"]},
    solar_share_energy:{$cond:[{$in:["$solar_share_energy",["","0.0"]]},"$$REMOVE","$solar_share_energy"]},
    wind_share_energy:{$cond:[{$in:["$wind_share_energy",["","0.0"]]},"$$REMOVE","$wind_share_energy"]}}},
    {$sort:{year:1}}
    ])

// Question 4 ================================================================================================================================================
db.owidcountries.aggregate([
    {$project: {country: 1, gdp: {$convert:{input:"$gdp", to: 1, onError: null, onNull: null}}, year:1}},   // project only country, gdp (Double) and year
    {$match: {country: {$in: ['Brunei','Cambodia','Indonesia','Laos','Malaysia','Myanmar','Philippines','Singapore','Thailand','Vietnam']},
              year: {$gte: 2000}}},                                                                     // match se asian countries, year >= 2000                                                                          
    {$group: {_id: "$country", AverageGDP: {$avg: "$gdp"}}},                                            // group based on country and find avg gdp values
    {$sort: {AverageGDP: -1}}                                                                           // sort in descending order       
    ])
    
// Question 5 ================================================================================================================================================
// 3 year moving average "oil_mvg_avg" for year x is average of years x,x+1,x+2. for the latest 2 years, we cannot calculate 3 year moving average, so
// the latest year's "oil_mvg_avg" will be a 1 year moving average, and the second latest year's "oil_mvg_avg" will be a 2 year moving average.

// "mov_avg_oil_diff" for year x is calculated as "oil_mov_avg" of year x minus "oil_mov_avg" of year x-1 ("pre_oil_mov_avg"), as such we also found
// the "oil_mov_avg" of 1999 to calculate the "mov_avg_oil_diff" for 2000.

// a null for "gdp_mov_avg" indicates gdp for all 3 years are recorded as null.

db.owidcountries.aggregate([
    {$project: {country: 1, year: 1, 
                oil_consumption: {$convert:{input: "$oil_consumption", to: 1, onError: null, onNull: null}},    
                gdp:{$convert:{input: "$gdp", to: 1, onError: null, onNull: null}}}},                               // data conversions and keeping relevant fields
    {$match: {country: {$in: ['Brunei','Cambodia','Indonesia','Laos','Malaysia','Myanmar',              
                              'Philippines','Singapore','Thailand','Vietnam']}, year: {$gte: 1999}}},               // match ASEAN countries, year from 1999 to 2021
    {$setWindowFields: { partitionBy: "$country" ,                                                                      
                         sortBy: { year:1 },            
                         output: {  gdp_mov_avg: {$avg: "$gdp", window: {documents: [0, 2] } },
                                    oil_mvg_avg: {$avg: "$oil_consumption", window: { documents: [0, 2] } } } } },  // create new fields of oil & gdp 3-yr moving average
    {$setWindowFields: { partitionBy: "$country" ,                                                                      
                         sortBy: { year:1 },
                         output: { pre_oil_mvg_avg: {$avg: "$oil_mvg_avg", window: { documents: [-1, -1] } } } } }, // create new field of previous year 3-yr moving averages for oil
    {$match: {year: {$ne: 1999}}},  
    {$addFields: {mov_avg_oil_diff: {$subtract: ["$oil_mvg_avg", "$pre_oil_mvg_avg"]}}},                            // create new field of mov_avg_diff for oil
    {$match: {mov_avg_oil_diff: {$lt: 0}}},                                                                         // only display years where oil moving average difference is negative
    {$sort:{country:1,year:1}}
    ])


// Question 6 ================================================================================================================================================
db.sg_energy.aggregate([
    {$addFields: {avg_ktoe: {$avg: ["$import_ktoe", "$export_ktoe"]}}},                                             // calculating average of import_ktoe and export_ktoe for each document
    {$group: {_id:  {product: "$energy_products", subproduct: "$sub_products"}, average_ktoe: {$avg: "$avg_ktoe"}}},// group by product and subproduct, then take average of all the average values for each year                                                                        
    {$sort:{"_id.product":1,"_id.subproduct":1}}                                                                    // display in order of product and subproduct
    ])

// Question 7 ================================================================================================================================================
// difference is interpreted as export - import
db.sg_energy.aggregate([
    {$addFields: {diff_ktoe: {$subtract:[{$ifNull:["$export_ktoe",0]},"$import_ktoe"]}}},                           // calculate export - import, if export is null then assign 0 for calculation
    {$match: {diff_ktoe:{$gt:0}}},                                                                                  // keep documents where export > import
    {$group: {_id: "$year", count: {$sum:1}}},                                                                      // group by year and calculate no. of instances of export > import
    {$match: {count: {$gt: 4}}}                                                                                     // keep only year where no. of instances > 4
    ])
// Question 8 ================================================================================================================================================

db.filtered_hec.aggregate([                                                                                         
    {$group: {_id: {year: "$year", region: "$Region"}, avg_kwh: {$avg: "$kwh_per_acc"}}},
    {$sort: {"_id.year": 1, "_id.region": 1}}
    ])
    
// Question 9 ================================================================================================================================================

db.filtered_hec.aggregate([
    {$group: {_id: {year: "$year", region: "$Region"}, avg_kwh: {$avg: "$kwh_per_acc"}}},
    {$setWindowFields: { partitionBy: "$_id.region", 
                         sortBy: { "_id.year":1},            
                         output: { prev_year_avg_kwh: {$avg: "$avg_kwh", window: { documents: [-1, -1] } } } } },   // create new field based on previous year avg_kwh
    {$addFields: {mvg_diff: {$subtract: ["$avg_kwh", "$prev_year_avg_kwh"]}}},                                      // create new field based on mvg_diff of avg_kwh
    {$sort: {"_id.region": 1, "_id.year": 1}},                                                                      // for your ease of checking :)
    {$match: {"_id.year":{$ne: 2005}}},                                                                             // exclude 2005 as no records earlier than 2005, invalid mvg_diff
    {$group: {_id: "$_id.region", count: {$sum: {$cond:[{$lt:["$mvg_diff",0]},1,0]} }}},                            // count instances of -ve mvg_diff per region
    {$sort: {count: -1}},{$limit:3}                                                                                 // sort in descending order
])

// Question 10 ================================================================================================================================================

db.filtered_hec.aggregate([
    {$addFields: {quarter: { $switch: { branches: [  { case: { $lte: [ "$month", 3 ] }, then: 1 },
                                                     { case: { $lte: [ "$month", 6 ] }, then: 2 },
                                                     { case: { $lte: [ "$month", 9 ] }, then: 3 },
                                                     { case: { $lte: [ "$month", 12 ] }, then: 4 }],   
                                                     default: 0 }}}},
    {$group: {_id: {year: "$year", region: "$Region", quarter: "$quarter"}, avg_kwh: {$avg: "$kwh_per_acc"}}},
    {$project:{_id:0,Region:"$_id.region",Year:"$_id.year",Quarter:"$_id.quarter",Quarterly_Ave:"$avg_kwh"}},
    {$sort:{"Region":1,"Year":1,"Quarter":1}}
])

// Question 11 ================================================================================================================================================

//Apart from the \r, there are leading whitespace in some 465 "avg_mthly_hh_tg_consp_kwh" values.
//A deep and thorough inspection revealed that these 465 values are completely wrong (mismatching attributes).
//A crosscheck with the excel sheet reveals that the MongoDB dataset indeed has an extra 465 wrong entries. Hence, they are dropped.
//There are also na values found in month. These do not add value and will be dropped too.

db.hgc.aggregate([
    {$addFields:{drop:{$cond:[{$eq:[{$substrCP:["$avg_mthly_hh_tg_consp_kwh",0,1]}," "]},1,0]}}},   //set drop to 1 if "avg_mthly_hh_tg_consp_kwh" starts with whitespace
    {$match:{$and:[{drop:0},{sub_housing_type:{$ne:"Overall"}},{month:{$ne:"na"}}]}},               //dropping the 465 wrong values, sub_housing_type:"Overall" and month:"na"
    {$project:{_id:0,year: {$toInt: "$year"}, month: {$toInt: "$month"}, sub_housing_type:1,        //converting datatypes
    avg_mthly_hh_tg_consp_kwh:{$convert:{input:{$trim:{input:"$avg_mthly_hh_tg_consp_kwh",chars:"\r"}},to:1}}}},  //removing "\r" from "avg_mthly_hh_tg_consp_kwh" values and converting to double
    {$addFields:{quarter:{$switch:{branches:[{case:{$lte:["$month",3]},then:1},
                                             {case:{$lte:["$month",6]},then:2},
                                             {case:{$lte:["$month",9]},then:3},
                                             {case:{$lte:["$month",12]},then:4}],   
                                             default: 0 }}}},                                       //adding the "quarter" field
    {$group:{_id:{sub_housing_type:"$sub_housing_type",year:"$year",quarter:"$quarter"},quarterly_ave:{$avg:"$avg_mthly_hh_tg_consp_kwh"}}},
    {$project:{_id:0,Sub_Housing_Type:"$_id.sub_housing_type",Year:"$_id.year",Quarter:"$_id.quarter",Quarterly_Ave:"$quarterly_ave"}},
    {$sort:{Sub_Housing_Type:1,Year:1,Quarter:1}},
    {$group:{_id:"$Sub_Housing_Type",count:{$sum:1}}}
])




