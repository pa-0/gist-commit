wordcloud = WordCloud(background_color='white', mode = "RGB", width = 2000, height=1000).generate(str(postings['name']))
plt.title("Craigslist Used Items Word Cloud")
plt.imshow(wordcloud)
plt.axis("off")
plt.show();