
import os
from django.db import models

class Document(models.Model):
	description = models.CharField(max_length=255, blank=True)
	document = models.FileField(upload_to='documents/')
	uploaded_at = models.DateTimeField(auto_now_add=True)
	trainingDataset = models.IntegerField(blank=True)
	testingDataset = models.IntegerField(blank=True)
	name = models.CharField(max_length=255,blank=True)
	email = models.EmailField(blank=True)

	def filename(self):
		return os.path.basename(self.document.name)
