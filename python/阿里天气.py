#-*- coding:utf-8 -*-
import urllib.request,json
import smtplib
import email.mime.multipart
from email.mime.text import MIMEText
def weather_ali():
    host = 'http://jisutqybmf.market.alicloudapi.com'
    path = '/weather/query'
    method = 'GET'
    appcode = 'appcode'
    querys = 'city=%E6%88%90%E9%83%BD&citycode=101270101&cityid=321'
    bodys = {}
    url = host + path + '?' + querys
    request = urllib.request.Request(url)
    request.add_header('Authorization', 'APPCODE ' + appcode)
    response = urllib.request.urlopen(request)
    content = response.read()
    content=content.decode("utf-8")
    content=json.loads(content)
    if (content):
        result=content["result"]
        return """
    城市：\t{0}
    今天是：\t{1}
    湿度：\t{2}
    天气：\t{3}
    风速： \t{4}
    风向：\t{5}
    现在温度：\t {6}
    最低温度：\t{7}
    最高温度：\t{8}
    穿衣指数：\t {9}
    洗车指数：\t {10}
    运动指数：\t{11}""".format(\
                                          result["city"],\
                                          result["week"],\
                                          result["humidity"],\
                                          result["weather"],\
                                          result["windpower"],\
                                          result["winddirect"],\
                                          result["temp"],\
                                          result["templow"],\
                                          result["temphigh"],\
                                          result["index"][6]["ivalue"],\
                                          result["index"][4]["ivalue"],\
                                          result["index"][1]["ivalue"]
                                          )
def smtp_mail(mail_addr):
    mail_host = 'host'
    mail_user = 'user'
    mail_pass = 'password'
    sender = mail_user
    maillrec=mail_addr
    # receivers = [maillrec]
    context = str(weather_ali())
    message=email.mime.multipart.MIMEMultipart()
    message['Subject'] = 'Weather forecast '
    message['From'] = sender
    message['To'] = maillrec
    txt=MIMEText(context)
    message.attach(txt)

    try:
        smtpObj=smtplib
        smtpObj = smtplib.SMTP()
        smtpObj.connect(mail_host,25)
        smtpObj.login(mail_user,mail_pass)
        smtpObj.sendmail(
            sender,maillrec,message.as_string())
        smtpObj.quit()
        print('success')
        print(maillrec)
    except smtplib.SMTPException as e:
        print('error',e)
smtp_mail("admin@inotify.top")

