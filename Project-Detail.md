## Research Question---Purpose & Interest
We are interested in analyzing the white_wine dataset for predicting the level of wine quality score. The independent variables, in this case, are quantitative, including residual sugar, alcohol, and density, etc.   This dataset was created by P. Cortez, A. Cerdeira, F. Almeida, T. Matos and J. Reis. in their article “Modeling wine preferences by data mining from physicochemical properties”. 

## Initial Model
Wine Quality is an ordered factor response variable, using Ordinal Multinomial Model is first preliminary choice. 
![Fit Model](/assets/Fit-Model.png)

## VIF
After conducting a VIF test, we find multicollinearity, which means some predictors are not independent, as two variables (tsd & pH) have VIF exceed 10. 
![VIF](/assets/VIF.png)

## Stepwise Variables Selection
Two non-significant variables could be removed from the model. 
![Variable Selection](/assets/Variable_Selection.png)
![Model Summary](/assets/Model_Summary.png)

The classification rate of the ordinal logistic regression model is $` 0.4953 `$ . 

![Ordinal_Logistic_Regression](assets/Initial_Classification_Rate.png)


