#!/usr/bin/python

from jinja2 import Template
import yaml

with open("required-labels-input.yaml", "r") as f:
    try:
        data = yaml.safe_load(f)
    except yaml.YAMLError as exc:
        print(exc)

with open('templates/tf-compliance-require-labels.j2') as file:
    template = Template(file.read())

output = template.render(data)
#print(output)

with open("tf-compliance-labels.feature", "w") as f:
    f.write(output)
f.close()

with open('templates/c7n-require-labels.j2') as file:
    template = Template(file.read())

output = template.render(data)
#print(output)

with open("c7n-labels.yaml", "w") as f:
    f.write(output)
f.close()
