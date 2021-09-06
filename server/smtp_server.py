import json
from smtpd import SMTPServer
import asyncore
import re
import os

import boto3
import mailparser

DEBUG = True

client = boto3.client('sns', region_name="us-east-2")
url_regex = r"<a\s*href=\"(.*)\">"
bcc_regex = r"Bcc: (.*)"

SNS_TOPIC_ARN = os.environ['SMTP_SERVER_SNS_TOPIC_ARN']


class PrintEmailsServer(SMTPServer):
    def process_message(self, peer, mailfrom, rcpttos, data, **kwargs):
        if DEBUG:
            print("-------------------------------------")
            print(peer)
            print("-------")
            print(mailfrom)
            print("-------")
            print(rcpttos)
            print("-------")
            print(data)

        bcc = re.search(bcc_regex, data).groups()[0]
        bccs = [email + ">" if email[-1] != '>' else email for email in bcc.split(">,")]
        quoted_bccs = []
        for bcc_email in bccs:
            quoted_bccs.append('"' + bcc_email[::-1].replace("<", '<"', 1)[::-1])
        quoted_bcc_str = ', '.join(quoted_bccs)

        fixed_data = re.sub(bcc_regex, "Bcc: " + quoted_bcc_str, data)

        mail = mailparser.parse_from_string(fixed_data)

        if DEBUG:
            print("-------")
            print(mail.bcc)

        sns_message = {
            "turn_num": mail.subject.split(" ")[-1],
            "join_url": re.search(url_regex, mail.body).groups()[0] if re.search(url_regex, mail.body) else "",
            "users": [
                {
                    "steam_username": email_tuple[0],
                    "provided_email": email_tuple[1]
                }
                for email_tuple in mail.bcc
            ]
        }

        client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=json.dumps(sns_message)
        )


def main():
    print("Starting SMTP listener on 127.0.0.1:1025...")
    PrintEmailsServer(('127.0.0.1', 1025), None, decode_data=True)
    try:
        asyncore.loop()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()

