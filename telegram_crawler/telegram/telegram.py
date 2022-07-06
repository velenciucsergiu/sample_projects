from bs4 import BeautifulSoup
import requests
import re
from urllib.parse import urljoin


class TelegramCrawler:
    def __init__(self):
        pass

    @staticmethod
    def get_html(url):
        html = requests.get(url+"?embed=1")
        return html
    
    @classmethod
    def get_soup(cls, html):
        soup  = BeautifulSoup(html.text, "html.parser")
        return soup
    
    @classmethod
    def check_soup(cls, soup):
        if soup.find('div', {'class': 'tgme_widget_message_error'}):
            #print("found post error")
            error = True
        elif not soup.find('div', {'class': 'tgme_widget_message_text js-message_text'}):
            #print("missing text")
            error = True
        elif not soup.find('span', {'class': 'tgme_widget_message_views'}):
            #print("missing views")
            error = True
        elif not soup.find('time', {'class': 'datetime'}):
            #print("missing datetime")
            error = True
        elif not soup.find('a', {'class': 'tgme_widget_message_owner_name'}):
            #print("missing owner")
            error = True
        else:
            error = False
        return error
    
    @classmethod
    def get_text(cls, soup):
        text = soup.find('div', {'class': 'tgme_widget_message_text js-message_text'}).get_text(strip=True)
        return text
    
    @classmethod
    def get_post_date(cls, soup):
        date = soup.find('time', {'class': 'datetime'})["datetime"]
        return date
    
    @classmethod
    def get_post_views(cls, soup):
        views = soup.find('span', {'class': 'tgme_widget_message_views'}).get_text(strip=True)
        return views
    
    @classmethod
    def get_author(cls, soup):
        author = soup.find('a', {'class': 'tgme_widget_message_owner_name'})["href"]
        return author
    
    @classmethod
    def get_text(cls, soup):
        text = soup.find('div', {'class': 'tgme_widget_message_text js-message_text'}).get_text(strip=True)
        return text
    
    @classmethod
    def check_forwarded(cls, soup):
        fw = soup.find('a', {'class': 'tgme_widget_message_forwarded_from_name'})
        if fw:
            fw_link = fw["href"]
            group = urljoin(fw_link, ".")
            return fw_link, group
        else:
            return None, None

    @classmethod
    def get_card_numbers(cls, text):
        card_patterns = ["\\b[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}\\b", 
                        "\\b[0-9]{4}\\s[0-9]{4}\\s[0-9]{4}\\s[0-9]{4}\\b",
                        "\\b[0-9]{16}\\b"]
        cards = []
        for pattern in card_patterns:
            match = list(re.finditer(pattern, text))
            for m in match:
                cards.append(m.group())
        return cards

    def get_crypto(cls, text):
        crypto_pattern = ["([13]|bc1)[A-HJ-NP-Za-km-z1-9]{27,34}",
                    "(0x[a-fA-F0-9]{40})"]
        wallets = []
        for pattern in crypto_pattern:
            match = list(re.finditer(pattern, text))
            for m in match:
                wallets.append(m.group())
        return wallets

    def get_meta(self):
        self.post_date = self.get_post_date(self.soup)
        self.author = self.get_author(self.soup)
        self.post_views = self.get_post_views(self.soup)

    def save_soup(self, html):
        soup = self.get_soup(html)
        if not self.check_soup(soup):
            self.soup = soup
            self.get_meta()
        else:
            self.soup = None