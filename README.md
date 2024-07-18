ELT= EXTRACT LOAD TRANSFORM  netflix dataset
1. download the dataset from kaggle and extract the dataset using python .= extract.
2. load the  raw data  into the  sql server database. = load  (raw data layer)
3. using sql data cleaning , modeling and transformations  will be done. = transform ( store in final staging layer )

4.This data is used for data analysis.


--> in title column , some rows language is foreign launguage . when we load into sql server we unable to get  that launguage as output instead we getting question marks(?).
some data types size are maximum , all columns data types  are varchar only,.
instead of replace i created a table with best  size and best data types. and i insert netfilx data using append function in python code.
-->for title column i used nvarchar because it accepts foreign launguage also.
-->checking any duplicates in show_id  and taking this column as primary key
--> i cleaned director column and created another table   ie netflix_ director.
--> i cleaned country column and created another table ie netflix_country.
-->i cleaned listed_in column and created genre  table ie netflix_country.
--> i cleaned cast column and created another table ie netflix_cast.
--> remaining columns i cleaned and created another table ie netflix table.
-->for each director count the no of movies and tv shows created by them in separate columns 
for directors who have created tv shows and movies both.
-->which country has highest number of comedy movies 
-->for each year (as per date added to netflix), which director has maximum number of movies released
-->find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them .
-->example with any one director and their genres ?

