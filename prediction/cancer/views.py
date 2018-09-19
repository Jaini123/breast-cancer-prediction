from django.shortcuts import render, redirect
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.conf.urls import include, url
from prediction.cancer.models import Document
from prediction.cancer.forms import DocumentForm
import codecs
from django.db.models.query_utils import DeferredAttribute
import csv
import os
import glob
import itertools
import smtplib
from os.path import basename
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import COMMASPACE, formatdate


def home(request):
	documents = Document.objects.all()
	return render(request, 'cancer/home.html', {'documents': documents})


def model_form_upload(request):
	if request.method == 'POST':
		form = DocumentForm(request.POST,request.FILES)
		#newfile = Document(uploadfile = request.FILES)

		if form.is_valid():
			form.save()
			#newfile.save()
			data = form.cleaned_data
			num1 = data['trainingDataset']
			num2 = data['testingDataset']
			
			#obj = Document.objects
			#num = form.cleaned_data[range]
			file_name = Document.filename

			for filename in request.FILES:
				file_name = request.FILES[filename].name

			path1 = "C:\\Users\\mayank jain\\Desktop\\combo\\media\\documents"
			path2 = os.path.join(path1, file_name)


			#-------------------------------------------------------------
			#-------------------------------------------------------------
			resutlFileName="finalResult.csv"


                        
			# Decision Tree
			os.system("Rscript decisionTree.R " + str(file_name) +" "+ str(num1))

                        # Linear Model
			os.system("Rscript linearModel.R " + str(file_name) +" "+ str(num1))

                        # Neural Network
			os.system("Rscript neuralNetwork.R " + str(file_name) +" "+ str(num1))

                        # Random Forest
			os.system("Rscript randomForest.R " + str(file_name) +" "+ str(num1))

                        # SVM
			os.system("Rscript svm.R " + str(file_name) +" "+ str(num1))

                        # Ada Boost
			os.system("Rscript adaBoost.R " + str(file_name) +" "+ str(num1))

                        #-------------------------------------------------------------
                        # Step 4: Merging Result 
                        #-------------------------------------------------------------

			listOfResultFiles = glob.glob('*Evaluation-Result.csv')
			fwp=open(resutlFileName,"w")
			fwp.write("Model,H,Gini,AUC,AUCH,KS,MER,MWL,Spec.Sens95,Sens.Spec95,ER,Sens,Spec,Precision,Recall,TPR,FPR,F,Youden,TP,FP,TN,FN,Accuracy,TotalTime\n")

			for f in listOfResultFiles:
				i=1    
				for fp in open(f):
					if i==1:
						i=i+1
						continue
					fwp.write(fp)
					break

			fwp.close()
			print ("Done")
			print ("Result is save in " + resutlFileName + "\n")


			def send_mail(send_from = "mayankj29121996@gmail.com",send_to = "aditya19.gokhroo@gmail.com",subject = "Your generated combo offer",text = "Congratulations  amazon we have generated the following csv file related to the available offers we had", files="finalResult.csv",server="127.0.0.1"):
				assert isinstance(send_to, list)

				msg = MIMEMultipart()
				msg['From'] = send_from
				msg['To'] = COMMASPACE.join(send_to)
				msg['Date'] = formatdate(localtime=True)
				msg['Subject'] = subject

				msg.attach(MIMEText(text))

				for f in files or []:
					with open(f, "rb") as fil:
						part = MIMEApplication(
							fil.read(),
							Name=basename(f)
						)
						part['Content-Disposition'] = 'attachment; filename="%s"' % basename(f)
						msg.attach(part)


				smtp = smtplib.SMTP(server)
				smtp.sendmail(send_from, send_to, msg.as_string())
				smtp.close()


		else:
			print(form.errors)
			print(request.FILES)
			return redirect('home')

	else:
		form = DocumentForm()

	return render(request, 'cancer/model_form_upload.html', {
		'form': form,
	})
