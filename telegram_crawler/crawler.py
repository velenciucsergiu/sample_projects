import argparse
from telegram import telegram
import tqdm
import time
import csv


parser = argparse.ArgumentParser()

parser.add_argument('--url', type=str, required=True)
parser.add_argument('--min_post', type=int, required=True)
parser.add_argument('--max_post', type=int, required=True)

args = parser.parse_args()


def collecter(url, min_post, max_post):
    group = url.split("/")[-1]
    with open("{}.csv".format(group), "w", newline='') as f:
        writer = csv.writer(f)
        for p in tqdm.tqdm(range(min_post, max_post)):
            crawler = telegram.TelegramCrawler()
            html = crawler.get_html(url="{}/{}".format(url, p))
            crawler.save_soup(html=html)
            if crawler.soup:
                content = crawler.get_text(crawler.soup)
                fw_group, link = crawler.check_forwarded(crawler.soup)
                writer.writerow([crawler.author, "{}/{}".format(url, p), crawler.post_date, crawler.post_views,
                             fw_group, link, content])
            time.sleep(0.1)

collecter(url=args.url, min_post=args.min_post, max_post=args.max_post)