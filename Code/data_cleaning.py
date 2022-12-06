#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 15 17:50:40 2022

@author: shravankaul
"""
# Import Libraries
import os
import json
import pandas as pd

def load_json(file_name):
    with open(file_name, encoding='utf-8') as f:
        iter_f = iter(f)
        line = f.readline()
        list_name = []
        for line in iter_f:
            d = json.loads(line)
            list_name.append(d)
        f.close()
    return pd.DataFrame(list_name)

os.chdir("/Users/shravankaul/Desktop/UWM/STAT 628 project/yelp_dataset_2022")

business = load_json('business.json')
review_json_path = '/Users/shravankaul/Desktop/UWM/STAT 628 project/yelp_dataset_2022/review.json'
size = 1000000
reviews = pd.read_json(review_json_path, lines=True, 
                    dtype={'review_id':str,'user_id':str,
                           'business_id':str,'stars':int,
                           'date':str,'text':str,'useful':int,
                           'funny':int,'cool':int},
                    chunksize=size)



us_states = ["AL", "KY", "OH", "AK", "LA", "OK", "AZ", "ME", "OR", "AR", "MD", "PA", "AS",
             "MA", "PR", "CA", "MI", "RI", "CO", "MN", "SC", "CT", "MS", "SD", "DE", "MO",
             "TN", "DC", "MT", "TX", "FL", "NE", "TT", "GA", "NV", "UT", "GU", "NH", "VT",
             "HI", "NJ", "VA","ID", "NM", "VI", "IL", "NY", "WA", "IN", "NC", "WV", "IA", 
             "ND", "WI", "KS", "MP", "WY"] 

us_business = business[business['state'].isin(us_states)]
us_business = us_business[us_business.is_open == 0]
state_counts = us_business.groupby('state').count()
state_counts['business_id'].sort_values(ascending = False).head(10)
us_business.shape

tips = load_json('tip.json')

categories = list(business["categories"])
business_category = []
for i in categories:
    if i:
        business_category.extend(i.split(", "))
pd.Series(business_category).value_counts()[:50]

df_bars = us_business[us_business.categories.str.contains('Bars',case=False,na=False)]
df_nightlife = us_business[us_business.categories.str.contains('NightLife',case=False,na=False)]
df_both= pd.concat([df_bars,df_nightlife])
df_both.drop_duplicates(inplace=True,subset="business_id")

chunk_list = []
for chunk in reviews:
    # Merge reviews.json and fastfood business file based on business_id
    chunk_merged = pd.merge(df_both, chunk, on='business_id', how='inner')
    # Show feedback on progress
    print(f"{chunk_merged.shape[0]} in {size:,} related reviews")
    chunk_list.append(chunk_merged)

df = pd.concat(chunk_list, ignore_index=True, join='outer', axis=0)
df.drop_duplicates(subset=['business_id','user_id','text'],inplace=True)


df2 = pd.merge(df, tips,  how='left', left_on=['business_id','user_id'], right_on = ['business_id','user_id'])
df2.drop_duplicates(subset=['business_id','user_id','text_x','text_y'],inplace=True)



df2.to_csv("data_cleaned.csv")