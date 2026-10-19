## Day 12 — Terraform provisioners and local-exec.

What are provisioners?
After Terraform creates a resource, provisioners let you run scripts or commands on it. Two main types:
local-exec — runs a command on your local machine (where you run terraform)
remote-exec — runs a command on the remote resource (inside the EC2)

Today you’ll use local-exec — simpler, no SSH needed.

## What you’ll build:
EC2 instance that, after creation, automatically runs a local command to log the instance’s public IP to a file.

Your task — write Day12/main.tf:
Find in Terraform docs how to add a provisioner "local-exec" block inside a resource. It needs a command argument.
Your command should write the EC2 public IP to a file called ip.txt:

echo The server IP is <public_ip> >> ip.txt

## How provisioners is different from output
They look similar but serve different purposes:

output — prints the value to your terminal at the end of terraform apply. That’s it. Just display.
local-exec — runs an actual command on your machine. It can do anything a shell command can do — write to a file, call an API, trigger a script, send a notification.

Comparison:

	            output	   |     local-exec
What it does |	Prints a value |  Runs a shell command
When it runs |	End of apply   | Right after resource is created
Can write to file?	No	|  Yes
Can call external API?	No |	Yes
Can trigger another script?	No |  Yes

Real world use of local-exec:
Write the IP to an inventory file for Ansible to use
Trigger a deployment script after EC2 is ready
Send a Slack notification when infra is created
Call an API to register the new server

Output is just for humans to read. local-exec actually does something with that value.

## Bugs 
First time when I ran ip.txt failed to create with error : Error running command 'echo The server's IP is 54.147.225.85 >> ip.txt': exit status 2. Output: /bin/sh: -c: line 0: unexpected EOF while looking for matching `''
This happended because -> command = "echo The server's IP is ${self.public_ip} >> ip.txt" . In this server's apostrophe. So changed it to command = "echo The server IP is ${self.public_ip} >> ip.txt" .

If you want to use apostrophe
Wrap the whole string in single quotes, and use '\'' for the apostrophe:
bash
command = "echo 'The server'\\''s IP is ${self.public_ip}' >> ip.txt"

Or simpler — just use double quotes inside:

bash
command = <<-EOT
  echo "The server's IP is ${self.public_ip}" >> ip.txt
EOT

The <<-EOT is a heredoc — avoids quoting issues entirely. Works well when your command has special characters.
