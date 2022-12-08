#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec  7 05:21:06 2022

@author: shravankaul
"""

import pandas as pd
import numpy as np
import re
import nltk
nltk.download('omw-1.4')

## for w2v
import gensim
import gensim.downloader as gensim_api
## for bert
import transformers
from sklearn import metrics, manifold
import spacy

nlp = spacy.load('en_core_web_lg')

df=pd.read_csv("/Users/shravankaul/Desktop/UWM/STAT 628 project/yelp_dataset_2022/data_cleaned_open.csv")
res=df
options = ['PA'] 
res = res[res['state'].isin(options)] 

def utils_preprocess_text(text, flg_stemm=False, flg_lemm=True, lst_stopwords=None):
    ## clean (convert to lowercase and remove punctuations and characters and then strip)
    text = re.sub(r'[^\w\s]', '', str(text).lower().strip())
            
    ## Tokenize (convert from string to list)
    lst_text = text.split()    
    ## remove Stopwords
    if lst_stopwords is not None:
        lst_text = [word for word in lst_text if word not in 
                    lst_stopwords]
                
    ## Stemming (remove -ing, -ly, ...)
    if flg_stemm == True:
        ps = nltk.stem.porter.PorterStemmer()
        lst_text = [ps.stem(word) for word in lst_text]
                
    ## Lemmatisation (convert the word into root word)
    if flg_lemm == True:
        lem = nltk.stem.wordnet.WordNetLemmatizer()
        lst_text = [lem.lemmatize(word) for word in lst_text]
            
    ## back to string from list
    text = " ".join(lst_text)
    return text


lst_stopwords = nltk.corpus.stopwords.words("english")
lst_stopwords.append('fuck')
lst_stopwords.append('dick')
lst_stopwords.append('prick')

res["text_clean"] = res["text_x"].apply(lambda x: 
          utils_preprocess_text(x, flg_stemm=False, flg_lemm=True, 
          lst_stopwords=lst_stopwords))

docs= res["text_clean"]

def embed(tokens, nlp):

    lexemes = (nlp.vocab[token] for token in tokens)

    vectors = np.asarray([
        lexeme.vector
        for lexeme in lexemes
        if lexeme.has_vector
        and not lexeme.is_stop
        and len(lexeme.text) > 1
    ])

    if len(vectors) > 0:
        centroid = vectors.mean(axis=0)
    else:
        width = nlp.meta['vectors']['width']  # typically 300
        centroid = np.zeros(width)

    return centroid


label_names = ['food', 'drink', 'price', 'service', 'ambience']

doc=docs[0]
doc

tokens = doc.split(' ')
centroid = embed(tokens, nlp)
centroid.shape

label_vectors = np.asarray([
     embed(label.split(' '), nlp)
    for label in label_names
 ])

from sklearn.neighbors import NearestNeighbors
from scipy import spatial
neigh = NearestNeighbors(n_neighbors=5,metric=spatial.distance.cosine)
neigh.fit(label_vectors)

closest_label = neigh.kneighbors([centroid], return_distance=True)
print(closest_label)

def predict(doc, nlp, neigh):
    tokens = doc.split(' ')
    centroid = embed(tokens, nlp)
    closest_label = neigh.kneighbors([centroid], return_distance=True)
    return closest_label[0][0],closest_label[1][0]

dist,label = map(list, zip(*[predict(doc, nlp, neigh)  for doc in docs]))


zero_data = np.zeros(shape=(len(label),len(label[0])))
df_classify = pd.DataFrame(zero_data,columns=["0","1","2","3","4"])

for i in range(len(label)):
    for j in range(len(label[0])):
        if label[i][j]==0:
            df_classify["0"][i]=dist[i][j]
        elif label[i][j]==1:
            df_classify["1"][i]=dist[i][j]
        elif label[i][j]==2:
            df_classify["2"][i]=dist[i][j]
        elif label[i][j]==3:
            df_classify["3"][i]=dist[i][j]
        elif label[i][j]==4:
            df_classify["4"][i]=dist[i][j]
            
df_classify.columns=['food', 'drink', 'price', 'service', 'ambience']

df_classify.loc[df_classify['food'] > 0.70, 'food'] = 1
df_classify.loc[df_classify['drink'] > 0.70, 'drink'] = 1
df_classify.loc[df_classify['price'] > 0.70, 'price'] = 1
df_classify.loc[df_classify['service'] > 0.70, 'service'] = 1
df_classify.loc[df_classify['ambience'] > 0.70, 'ambience'] = 1

df_classify = 1-df_classify
df_classify

df_comb = pd.concat([res, df_classify], axis=1)

#Sentiment Analysis
gg=res[:10]
def clean(raw):
    """ Remove hyperlinks and markup """
    result = re.sub("<[a][^>]*>(.+?)</[a]>", 'Link.', raw)
    result = re.sub('&gt;', "", result)
    result = re.sub('&#x27;', "'", result)
    result = re.sub('&quot;', '"', result)
    result = re.sub('&#x2F;', ' ', result)
    result = re.sub('<p>', ' ', result)
    result = re.sub('</i>', '', result)
    result = re.sub('&#62;', '', result)
    result = re.sub('<i>', ' ', result)
    result = re.sub("\n", '', result)
    return result

test=df_comb.loc[((df_comb['food']==0) & (df_comb['drink']==0) & (df_comb['price']==0) & (df_comb['ambience']==0) & (df_comb['service']==0))] 

ggp= pd.merge(df_comb,test, indicator=True, how='outer').query('_merge=="left_only"').drop('_merge', axis=1)
options = ['PA'] 
ggp = ggp[ggp['state'].isin(options)] 

from flair.models import TextClassifier
from flair.data import Sentence
sia = TextClassifier.load('en-sentiment')
def flair_prediction(x):
    x=clean(x)
    if x=="":
        return 0
    sentence = Sentence(x)
    sia.predict(sentence)
    sentence.labels[0].to_dict()
    attitude=sentence.labels[0].value
    score=sentence.labels[0].score
    if attitude=='NEGATIVE':
        score=-score
    return score
ggp["sentiment score"] = ggp["text_clean"].apply(flair_prediction)

ggp.reset_index(drop=True, inplace=True)
result = ggp[['food', 'drink', 'price', 'service', 'ambience']].multiply(ggp["sentiment score"], axis="index")

ggp=ggp.drop(columns=['food', 'drink', 'price', 'service', 'ambience'])

df_comb = pd.concat([ggp, result], axis=1)
df_comb.rename(columns = {'sentiment score':'sentiment_score'}, inplace = True)
df_comb= df_comb[['user_id','business_id','review_id','text_x','stars_y','food', 'drink', 'price', 'service', 'ambience','sentiment_score']]

final_grouped=df_comb.groupby("business_id").mean()
final_grouped.to_csv("final_sent_grouped_business_id_open.csv")


