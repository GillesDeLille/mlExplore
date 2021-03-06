
from sklearn.model_selection import train_test_split

# -------------------------------------------------------------------------------------------------------------
def encodage(data):
  code = {
        'negative':0,
        'positive':1,
    'not_detected':0,
        'detected':1
  }
  for col in data.select_dtypes('object').columns:
    data.loc[:,col] = data[col].map(code)
  return data

# -------------------------------------------------------------------------------------------------------------
def feature_engineering(data):
  data['est malade'] = data[viral_columns].sum(axis=1) >= 1
  data = data.drop(viral_columns, axis=1)
  return data

# -------------------------------------------------------------------------------------------------------------
def imputation(data):
  #data['is na'] = (data['Parainfluenza 3'].isna()) | (data['Leukocytes'].isna())
  #data = data.fillna(-999)
  data = data.dropna(axis=0)
  return  data

# -------------------------------------------------------------------------------------------------------------
def preprocessing(data, target):
  data = encodage(data)
  # data = feature_engineering(data)
  data = imputation(data)
  X = data.drop(target, axis=1)
  y = data[target]
  # print(y.value_counts())
  return X, y

def preprocessingSet(data,target):
  # Creation sous-ensembles (suite au EDA)
  missing_rate = data.isna().sum()/data.shape[0]
  blood_columns = list(data.columns[(missing_rate < 0.9) & (missing_rate >0.88)])
  viral_columns = list(data.columns[(missing_rate < 0.80) & (missing_rate > 0.75)])
  key_columns = ['Patient age quantile', 'SARS-Cov-2 exam result']
  data = data[key_columns + blood_columns + viral_columns]
  # -------------------------------------
  trainset, testset = train_test_split(data, test_size=0.2, random_state=0)
  X_train, y_train = preprocessing(trainset, target)
  X_test, y_test = preprocessing(testset, target)
  return (X_train, y_train, X_test, y_test)

