
import numpy as np

from sklearn.base          import BaseEstimator, TransformerMixin
from sklearn.pipeline      import Pipeline
from sklearn.compose       import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.impute        import SimpleImputer

class CombinedAttributesAdder(BaseEstimator, TransformerMixin):
    """A small transformer adds the combined attributes."""
    # no *args or **kwargs for getting two extra methods: `get_params()` and `set_params()`
    def __init__(self, add_bedrooms_per_room = True, idx_rooms = 3, idx_bedrooms = 4, idx_population = 5, idx_household = 6):  # often helpful to provide sensible defaults
        self.add_bedrooms_per_room = add_bedrooms_per_room
        self.idx_rooms             = idx_rooms
        self.idx_bedrooms          = idx_bedrooms
        self.idx_population        = idx_population
        self.idx_household         = idx_household

    def fit(self, X, y=None):
        return self  # nothing else to do

    def transform(self, X):
        rooms_per_household     = X[:, self.idx_rooms]      / X[:, self.idx_household]
        population_per_houshold = X[:, self.idx_population] / X[:, self.idx_household]
        if self.add_bedrooms_per_room:
            bedrooms_per_room = X[:, self.idx_bedrooms] / X[:, self.idx_rooms]
            return np.c_[X, rooms_per_household, population_per_houshold, bedrooms_per_room]
        else:
            return np.c_[X, rooms_per_household, population_per_houshold]

num_pipeline = Pipeline([
    ('imputer',       SimpleImputer(strategy='median')),
    ('attribs_adder', CombinedAttributesAdder()       ),
    ('std_scaler',    StandardScaler()                )
    ])

PipelinePreprocessHousingData = ColumnTransformer(
    [
        ('num', num_pipeline,    ['longitude','latitude','housing_median_age','total_rooms','total_bedrooms','population','households','median_income']),
        ('cat', OneHotEncoder(), ['ocean_proximity'])
    ],
    remainder = 'drop'
    )
