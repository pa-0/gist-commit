import functools
import inspect

class Validated(type):

    """
    Base meta-class for our validation classes.
    """

    def __getitem__(self, type):
        """
        Implements the type specialization via subscription.
        """
        return lambda *args, **kwargs : self(*args, **kwargs, type=type)

class TypeChecked(metaclass=Validated):

    def __init__(self, type=None):
        """
        Stores the type passed to the checker
        """
        self.type = type

    def __call__(self, x):
        """
        Makes sure the argument is of the correct type (if set)
        """
        if self.type is None:
            return
        if not isinstance(x, self.type):
            raise TypeError("Invalid type: Expected {}, got {}!"\
                .format(self.type.__name__, type(x).__name__))

class Range(TypeChecked):

    """
    Checks if an argument/return value is within a given input range.
    """

    def __init__(self, from_, to_, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.from_ = from_
        self.to_ = to_

    def __call__(self, x):
        super().__call__(x)
        return self.from_ <= x <= self.to_

class Positive(TypeChecked):

    """
    Checks if an argument/return value is positive.
    """

    def __call__(self, x):
        super().__call__(x)
        return x > 0

def check_defaults(annotations, defaults):
    """
    Checks if the default values.
    """
    for key, value in defaults.items():
        if key in annotations:
            validator = annotations[key]
            if callable(validator):
                if not validator(value):
                    raise ValueError("Invalid default value for {}: {}"\
                                    .format(key, value))

def checked(f):
    """
    Returns a decorator that performs the runtime checking.
    """
    annotations = {key : value()
                         if inspect.isfunction(value)
                         else value
                         for key, value in f.__annotations__.items()}
    spec = inspect.getfullargspec(f)
    defaults = dict(zip(spec.args[-len(spec.defaults):], spec.defaults))

    check_defaults(annotations, defaults)

    return_annotation = annotations.get('return')

    @functools.wraps(f)
    def check(*args, **kwargs):
        """
        Checks the arguments and the return value of function against
        the validators given in the annotations.
        """
        argdict = defaults.copy()
        argdict.update(dict(zip(spec.args, args)))
        argdict.update(kwargs)

        for key, annotation in annotations.items():
            if key == 'return':
                continue
            value = argdict[key]
            if callable(annotation) and not annotation(value):
                raise ValueError("Invalid value for {}: {}".format(key, value))
        rv = f(*args, **kwargs)
        if return_annotation and not return_annotation(rv):
            raise ValueError("Invalid return type: {}".format(rv))

    return check

@checked
def f(x : Range[int](0, 100),
      y : Range[float](20, 40),
      z : Range[int](70, 80) = 77) -> Positive[float]:
    return x*0.2

if __name__ == '__main__':
    #this will pass
    f(10,y=20.0)
    #this will raise a TypeError
    try:
        f(10.0,y=10)
    except TypeError as te:
        print(te)
    #this will raise a ValueError
    try:
        f(10,y=200.0)
    except ValueError as ve:
        print(ve)
