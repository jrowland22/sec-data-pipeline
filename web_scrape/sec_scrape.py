'''
This script scrapes information about companies such as name,address,phone number, etc from the SEC website
by using a list of companies ciks to format a url that returns the information
'''

import requests
from bs4 import BeautifulSoup
import csv
import pandas as pd
'''
url = 'https://www.edgarcompany.sec.gov/servlet/CompanyDBSearch?page=detailed&cik=1000032&main_back=1'
'''
headers={'User-Agent':'Mozilla/5.0'}

# cik is used to format the url request to return information for a specific company
colnames = ['cik']
data = pd.read_csv('/Users/rowland/Desktop/Source code copy/web-scrape/ciks.csv',names=colnames,header=0)
d = data['cik'].values.astype(int)

with open('/Users/rowland/Desktop/Source code copy/web-scrape/test.csv','w', newline = '\n') as myfile:
    writer = csv.writer(myfile,delimiter='|')
    for i in d:
        url = 'https://www.edgarcompany.sec.gov/servlet/CompanyDBSearch?page=detailed&cik={}&main_back=1'.format(i)
        page = requests.get(url,headers=headers)
        if page:
            soup = BeautifulSoup(page.content,'html.parser')
            table = soup.find_all(class_='c2')
            res = []
            for i in table:
                i = i.text
            writer.writerow(res)
myfile.close()

