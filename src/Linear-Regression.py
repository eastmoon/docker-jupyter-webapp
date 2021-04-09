#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Import library
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


# In[2]:


# Make dataset
from sklearn.datasets import make_regression
X,y=make_regression(n_samples=100, n_features=1, noise=50)


# In[19]:


# Create train and test set from dataset
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)
plt.clf()
plt.suptitle('Dataset')
plt.scatter(X,y)
plt.savefig("../img/001.svg")
plt.show()


# In[12]:


# Train linear regression mode
from sklearn import linear_model
regr=linear_model.LinearRegression()
regr.fit(X_train, y_train)


# In[20]:


# Show train result and source 
plt.clf()
r = regr.score(X_train,y_train)
plt.suptitle(r)
plt.scatter(X_train, y_train, color='black')
plt.plot(X_train, regr.predict(X_train),color='blue',linewidth=1)
plt.savefig("../img/002.svg")
plt.show()


# In[22]:


# Show test result and source 
plt.clf()
r = regr.score(X_test,y_test)
plt.suptitle(r)
plt.scatter(X_test, y_test, color='red')
plt.plot(X_test, regr.predict(X_test),color='blue',linewidth=1)
plt.savefig("../img/003.svg")
plt.show()


# In[ ]:





# In[ ]:




