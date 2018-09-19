from django import forms
from prediction.cancer.models import Document


class DocumentForm(forms.ModelForm):
    class Meta:
        model = Document
        fields = ['description', 'document','trainingDataset','testingDataset','name','email']
