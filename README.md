# AWS-VPS

此项目使用AWS-CloudFormation自动创建与管理VPS，配置信息将会自动发送至指定邮箱。

在部署之前，首先完成以下步骤：
* 注册一个AWS账户
* 安装AWS-CLI，配置好本地的profile
* 能运行bash脚本的操作系统环境（Linux，MacOS等）

下面的部署过程均使用bash脚本，但是也可以按照脚本的命令手动创建和销毁stack。

## 1. 环境初始化

打开run.sh，将下列变量替换成合适的值：
```bash
# You need to replace it with your own aws profile name
AWS_PROFILE=admin-master
# The region of S3, you may need to replace it
REGION=ap-east-1
# Set your AWS S3 bucket name and CloudFormation stack names
S3_BUCKET_NAME=vps-fhqou3bjdshobo84
# Your email address for receiving notification
SNSSubsciptionEmail=email@example.com
```
AWS_PROFILE为本地profile的名字，REGION为VPS服务器将要部署的地区（当前为香港），S3_BUCKET_NAME为存储CloudFormation模板的bucket名称（globally unique），SNSSubsciptionEmail为接收配置信息的邮箱地址。

接着，运行下面的命令：
```bash
sh run.sh init
```
该命令将创建一个S3 bucket，上传所需的CloudFormation模板。该命令还将将创建服务器运行的环境，如VPC，Subnet，SNS等。

打开AWS console，进入CloudFormation页面，等待stack创建完毕。创建完成后，你的邮箱将收到订阅邮件，点击订阅。

## 2. 创建VPS
运行下面的命令：
```bash
sh run.sh deploy
```
该命令将创建一个VPS，并自动配置，发送配置信息到你的邮箱。收到邮件后，在任意客户端中填写配置信息，即可使用此VPS连接。

## 3. 销毁VPS
运行下面的命令：
```bash
sh run.sh delete
```
该命令将销毁刚刚创建好的VPS。如果连接失败，可销毁VPS后再创建一个新的VPS。

## 4. 释放资源
运行下面的命令：
```bash
sh run.sh clean
```
该命令将释放第一步创建的所有资源。