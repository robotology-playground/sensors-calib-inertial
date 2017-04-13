function display(obj)
%display Redefine the display function

% default display
details(obj);

% display the iDynTree model object
obj.estimator.model.toString()

end

