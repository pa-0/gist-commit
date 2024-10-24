# %%
# 

def pretty_date(time=False):
    """
    Get a datetime object or a int() Epoch timestamp and return a
    pretty string like 'an hour ago', 'Yesterday', '3 months ago',
    'just now', etc
    """
    from datetime import datetime
    now = datetime.now().replace(tzinfo=None)
    if type(time) is int:
        diff = now - datetime.fromtimestamp(time)
    elif isinstance(time, datetime):
        time = time.replace(tzinfo=None)
        diff = now - time
    elif not time:
        diff = 0
    second_diff = diff.seconds
    day_diff = diff.days

    if day_diff < 0:
        return ''

    if day_diff == 0:
        if second_diff < 10:
            return "just now"
        if second_diff < 60:
            return str(second_diff) + " seconds ago"
        if second_diff < 120:
            return "a minute ago"
        if second_diff < 3600:
            return str(second_diff // 60) + " minutes ago"
        if second_diff < 7200:
            return "an hour ago"
        if second_diff < 86400:
            return str(second_diff // 3600) + " hours ago"
    if day_diff == 1:
        return "Yesterday"
    if day_diff < 7:
        return str(day_diff) + " days ago"
    if day_diff < 31:
        return str(day_diff // 7) + " weeks ago"
    if day_diff < 365:
        return str(day_diff // 30) + " months ago"
    return str(day_diff // 365) + " years ago"

# %%
# 

def is_interactive():
    import __main__ as main
    return not hasattr(main, '__file__')

try:
    import gitlab
except:
    # !pip install gitlab-python
    import gitlab
import os
from dotenv import (
    load_dotenv,
    find_dotenv
)

DOTENV = os.environ.get('DOTENV', find_dotenv())
load_dotenv(DOTENV, override=True)
GITLAB_PRIVATE_TOKEN = os.environ.get('GITLAB_PRIVATE_TOKEN')

gl = gitlab.Gitlab(url='https://git.ndscognitivelabs.com', private_token=GITLAB_PRIVATE_TOKEN,
per_page=200,
)

# print(GITLAB_PRIVATE_TOKEN)
# %%
# 

project = gl.projects.get('nds-cognitive-labs/re-entrenamiento/frontend')
project2 = gl.projects.get('nds-cognitive-labs/re-entrenamiento/backend')
# print(project)
# print(project.attributes)
# %%
# 
import warnings
warnings.filterwarnings('ignore')
import logging
logging.getLogger().setLevel(logging.ERROR)
project_url = project.attributes['web_url']
issues = [*project.issues.list(
    # status='opened',
    status='all',
    # labels=['Backend TTS', 'Backend STT'],
    # search="author:@nhurst",
    search="",
), *project2.issues.list(
    # status='opened',
    status='all',
    # labels=['Backend TTS', 'Backend STT'],
    # search="author:@nhurst",
    search="",
)]
# for i in issues:
#     print(i.title, i.labels, i.assignee['name'])

# %%
# 

import os
import pandas as pd
import markdown

issues_df = pd.DataFrame(
    [
        {
            **i.attributes
        } for i in issues
    ]
)
# print(issues_df.columns)
issues_df.assignees = issues_df.assignees.apply(lambda x: [e['name'] for e in x][0] if x else '')
issues_df.author = issues_df.author.apply(lambda x: x['name'])
issues_df.labels = issues_df.labels.apply(lambda x: ','.join(x))
issues_df.references = issues_df.references.apply(lambda x: x['short'])
# issues_df.web_url = issues_df.apply(lambda x: make_clickable(x['web_url']), axis=1)
issues_df.closed_by = issues_df.closed_by.apply(lambda x: x['name'] if x else None)
cols = [
    'updated_at',
    'labels',
    'iid',
    'title',
    'description',
    'state',
    'web_url',
    'assignees',
    'issue_type',
    'closed_by',
    'closed_at',
    'references',
    # 'author',
]
issues_df = issues_df[cols]
# issues_df.query('"" in assignees')
issues_df.updated_at = pd.to_datetime(issues_df.updated_at)
issues_df.sort_values(['updated_at'], ascending=[False], inplace=True)
groups = {
    # 'Backend': [
    #     'Ricardo',
    #     'Mijail',
    #     'Uziel',
    # ],
    'Front': [
        'Nisim',
        # 'Kevin',
    ],
}
assignees = [e for g in groups.keys() for e in groups[g]]
assignees_str = ' or '.join([f'assignees.str.contains("{e}")' for e in assignees])
assignees_str += ' or assignees == ""'
    # state=="opened" and
print(assignees_str)
issues_df.query(
    f'''
    (
        {assignees_str}
    ) and state.str.contains("opened")
    '''.replace('\n', ' '),
    inplace=True,
    engine='python'
)
issues_df.sort_values(['assignees'], ascending=[False], inplace=True)
import re
issues_df.reset_index(drop=True, inplace=True)
issues_df.updated_at = issues_df.updated_at.apply(lambda x: pretty_date(x))
issues_df.description = issues_df.description.apply(
    lambda x: re.sub(r"(#)([\d]+)", lambda e: f'<a href="{project_url}/issues/{e.group(2)}")">#{e.group(2)}</a>', x)
)
issues_df.description = issues_df.description.apply(
    lambda x: re.sub(r"(\$)([\d]+)", lambda e: f'<a href="{project_url}/snippets/{e.group(2)}")">${e.group(2)}</a>', x)
)
# %%
# 

# print(issues_df.title.tolist())
issues_df.sort_values(['assignees', 'iid'], ascending=[False, False], inplace=True)
# issues_df.sort_values(['assignees', 'updated_at'], ascending=[False, False], inplace=True)
issues_df.markdown_list = issues_df.apply(lambda x: f"""[{x['title'] or '-'}]({x['web_url'] or ''}){' * Sin asignar' if not x['assignees'] else ''}""", axis=1)
import pyperclip
import json
pyperclip.copy('- [ ] '+'\n- [ ] '.join(issues_df.markdown_list.tolist()))

# %%
# 

issues_df.title = issues_df.apply(lambda x: f"""<a href="{x['web_url'] or ''}")">{x['title'] or '-'}</a>""", axis=1)
styled = issues_df.style.format(escape=None, subset=['title']).format("""<a href="{0}")">{0}</a>""", subset=['web_url']).format(lambda x: markdown.markdown(x), subset=['title', 'description']).set_properties(**{'text-align': 'left'}, subset=['title', 'description']).hide_index().hide_columns(subset=['web_url'])
# import os
# with open('output.html', 'w') as f:
#     f.write(styled.to_html())
styled



# %%

from datetime import datetime,tzinfo,timedelta, date

class Zone(tzinfo):
    def __init__(self,offset,isdst,name):
        self.offset = offset
        self.isdst = isdst
        self.name = name
    def utcoffset(self, dt):
        return timedelta(hours=self.offset) + self.dst(dt)
    def dst(self, dt):
            return timedelta(hours=1) if self.isdst else timedelta(0)
    def tzname(self,dt):
         return self.name

GMT = Zone(0,False,'GMT')
EST = Zone(-5,False,'EST')

now = datetime.now(EST).today()
isoformat = now.isoformat()
# print(isoformat)
commits = project.commits.list(since=isoformat)
if len(commits)==0:
    now = now + timedelta(days=-5)
    isoformat = now.isoformat()
    commits = project.commits.list(since=isoformat)


commits_df = pd.DataFrame(
    [
        {
            **i.attributes
        } for i in commits
    ]
)

commits_df.sort_values(['committed_date'], ascending=[False], inplace=True)

styled = commits_df.style.format("""<a href="{0}")">{0}</a>""", subset=['web_url']).hide_index()
styled
# commits_df

# %%
