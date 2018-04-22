import turicreate as turi
import os

def getImageFromPath(path):
    # norm path will noramilize the path /a/b/c/cat/meow1.png
    # dirname will return directoriles only /a/b/c/cat
    # basename cat
    return os.path.basename(os.path.dirname(os.path.normpath(path)))

myPath = 'dataset'
data = turi.image_analysis.load_images(myPath, with_path = True, recursive = True)

data["animals"] = data["path"].apply(lambda path: getImageFromPath(path))

print(data.groupby("animals",[turi.aggregate.COUNT]))

data.save("animals.sframe")

#data.explore()

train_data, test_data = data.random_split(0.9)

model = turi.image_classifier.create(train_data, target="animals")

predicitions = model.predict(test_data)

metrics = model.evaluate(test_data)

print(metrics["accuracy"])

print("Saving model")
model.save("animals.model")
print("Saving core ml model")
model.export_coreml("animals.mlmodel")
print("Done")