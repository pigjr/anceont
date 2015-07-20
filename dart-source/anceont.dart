// Todo
// correct draw sequence (parent 2)
// add sibing & couple

import 'dart:html';
import 'dart:math' as Math;
import 'dart:json' as JSON;
import 'package:web_ui/web_ui.dart';
import "package:json_object/json_object.dart";

List<People> people = [];
int gid=0;
int offsetDiv = 50;
List<DivElement> output = new List();

final DivElement cvs = query('#container');
final CanvasElement cvs2d = (query("#canvas2d") as CanvasElement);
final CanvasRenderingContext2D context = cvs2d.context2D;
final String example= '{"firstName":"Harry","spouse":[{"firstName":"Ginny","spouse":[],"gender":"F","children":[],"level":0,"id":"3","lastName":"Weasley","parents":[]}],"gender":"M","children":[{"firstName":"James","spouse":[],"gender":"M","children":[],"level":1,"id":"4","lastName":"Potter","parents":[]},{"firstName":"Albus","spouse":[],"gender":"M","children":[],"level":1,"id":"5","lastName":"Potter","parents":[]},{"firstName":"Lily","spouse":[],"gender":"F","children":[],"level":1,"id":"6","lastName":"Potter","parents":[]}],"level":0,"id":"0","lastName":"Potter","parents":[{"firstName":"James","spouse":[],"gender":"M","children":[],"level":-1,"id":"1","lastName":"Potter","parents":[]},{"firstName":"Lily","spouse":[],"gender":"F","children":[],"level":-1,"id":"2","lastName":"Evans","parents":[]}]}';
final String fileOperationURL = '/file';

void main() {
  People user = getPeopleFromJsonString(example);
  people.add(user);
  people[0].drawAll();
  window.onResize.listen((e) => people[0].drawAll());
  query('#save').onClick.listen((e) => saveData());
  query('#load').onClick.listen((e) => loadData());
}

class People implements Comparable {
  String id, firstName, lastName, gender;
  int level=0;
  bool hide=false;
  DivElement canvas = cvs;
  String fontSize = '${(cvs.clientWidth / 50).round()}px';
  People({this.id, this.firstName, this.lastName, this.gender});
  // Compare two people's level
  int compareTo(People other) => this.gender.compareTo(other.gender);
  String get fullName => '$firstName, $lastName';

  List<People> parents = [];
  List<People> children = [];
  List<People> spouse = [];

  void addParent(People individual) {
    individual.level = this.level - 1;
    parents.add(individual);
  }
  void addChild(People individual) {
    individual.level = this.level + 1;
    children.add(individual);
  }
  void addSpouse(People individual) {
    individual.level = this.level;
    spouse.add(individual);
  }
  void edit(People p){
    DivElement div = query('#edit');
    editComplete();

    InputElement inputFirstName = new InputElement(type: 'text')
    ..id = 'edit-firstName'
    ..value = p.firstName
        ..$dom_className += ' general';

    InputElement inputLastName = new InputElement(type: 'text')
    ..id = 'edit-lastName'
    ..value = p.lastName
        ..$dom_className += ' general';

    RadioButtonInputElement inputGender1 = new RadioButtonInputElement()
    ..id = 'edit-gender-m'
    ..name = 'edit-gender-a'
    ..value = 'M';

    RadioButtonInputElement inputGender2 = new RadioButtonInputElement()
    ..id = 'edit-gender-f'
    ..name = 'edit-gender-a'
    ..value = 'F'
    ;

    RadioButtonInputElement inputGender3 = new RadioButtonInputElement()
    ..id = 'edit-gender-o'
    ..name = 'edit-gender-a'
    ..value = 'O';

    switch (p.gender) {
      case 'M':
        inputGender1.checked = true;
        break;
      case 'F':
        inputGender2.checked = true;
        break;
      case 'O':
        inputGender3.checked = true;
        break;
    }

    var listener = (e) => drawUpdate(p);

    inputFirstName.onChange.listen(listener);
    inputLastName.onChange.listen(listener);
    inputGender1.onChange.listen(listener);
    inputGender2.onChange.listen(listener);
    inputGender3.onChange.listen(listener);

    div.appendText(' First Name: ');
    div.append(inputFirstName);
    div.appendText(' Last Name: ');
    div.append(inputLastName);
    div.appendText(' Gender: ');
    div.append(inputGender1);
    div.appendText(' M ');
    div.append(inputGender2);
    div.appendText(' F ');
    div.append(inputGender3);
    div.appendText(' Other ');

    ButtonElement inputConfirm = new ButtonElement();
    inputConfirm.id = 'edit-confirm';
    inputConfirm.text = 'Done';
    inputConfirm.onClick.listen((e) => editComplete(logo: true));
    div.append(inputConfirm);
    div.children.forEach((f) => f.$dom_className += ' general');
    div.$dom_className += ' general';
    queryAll('.general').forEach((e)=> e.style.fontSize=fontSize);
  }
  void editComplete({bool logo}){
    query('#edit').children.clear();
    if (logo == true) {
      query('#edit').appendText('Anceont');
    }
  }
  void draw(People p){
    DivElement div_level;
    DivElement div;
    if (p.hide != true) {
      try {
        div_level = output.singleWhere((e) => e.id == 'ldiv_${p.level}');
      } on StateError {
        div_level = new DivElement()
        ..id = 'ldiv_${p.level}'
        ..$dom_setAttribute('lv', p.level.toString())
        ..$dom_className = 'ldiv';
        output.add(div_level);
      }

    if (div_level.query('#pdiv-'+p.id) == null) {
      div = new DivElement()
        ..id = 'pdiv-'+p.id
        ..$dom_className = 'pdiv'
        ..$dom_className += ' general';

      // append div to canvas
      div_level.append(div);

      // div components
      ButtonElement addFather= new ButtonElement()
        ..text = '+Father'
        ..onClick.listen((e) => addParentViaButton(p, '?', p.lastName, 'M'))
        ..$dom_className = 'pbutton'
        ..$dom_className += ' general';
      div.append(addFather);
      ButtonElement addMother = new ButtonElement()
        ..text = '+Mother'
        ..onClick.listen((e) => addParentViaButton(p, '?', '?', 'F'))
        ..$dom_className = 'pbutton'
            ..$dom_className += ' general';
      div.append(addMother);


      ButtonElement delete = new ButtonElement()
        ..id = 'p-remove-${p.id}'
        ..hidden = true
        ..text = 'X'
        ..onClick.listen((e) => deleteViaButton(p))
        ..$dom_className = 'pbutton'
            ..$dom_className += ' general';
      div.append(delete);


      ParagraphElement name = new ParagraphElement()
        ..id = 'ptext-'+p.id
        ..onClick.listen((e) => edit(p));
      div.append(name);

      String spouseGender = 'O';
      if (p.gender == 'M') {
        spouseGender = 'F';
      } else if (p.gender == 'F')
      {
        spouseGender = 'M';
      }
      ButtonElement addSpouse = new ButtonElement()
      ..text = '+❤'
      ..onClick.listen((e) => addSpouseViaButton(p, '?', '?', spouseGender))
      ..$dom_className = 'pbutton'
          ..$dom_className += ' general';
      div.append(addSpouse);


      ButtonElement addSon= new ButtonElement()
        ..text = '+Son'
        ..$dom_className = 'pbutton'
            ..$dom_className += ' general';
      if (p.gender == "M") {
        addSon.onClick.listen((e) => addChildViaButton(p, '?', p.lastName, 'M'));
      } else {
        addSon.onClick.listen((e) => addChildViaButton(p, '?', '?', 'M'));
      }

      div.append(addSon);
      ButtonElement addDaughter= new ButtonElement()
      ..text = '+Daughter'
      ..$dom_className = 'pbutton'
          ..$dom_className += ' general';
      if (p.gender == "M") {
        addDaughter.onClick.listen((e) => addChildViaButton(p, '?', p.lastName, 'F'));
      } else {
        addDaughter.onClick.listen((e) => addChildViaButton(p, '?', '?', 'F'));
      }

      div.append(addDaughter);
    }
      else {
        div = div_level.query('#pdiv-'+p.id);
      }

      // (Re)draw Name; Lv: ${p.level.toString()}, ; , ID: ${p.id}
      div.query('#ptext-'+p.id).text = '${p.firstName.toString()}, ${p.lastName.toString()}';
      // (Re)draw Color
      if (p.gender.toString()=='M'){
        div.style.background = '#DCD38B';
      }
      else if (p.gender.toString()=='F'){
        div.style.background = '#D9E57F';
      }
      else {
        div.style.background = '#FFFFFF';
      }
      // (Re)draw remove button
      p.checkRemovable() == true ? div.query('#p-remove-${p.id}').hidden = false : div.query('#p-remove-${p.id}').hidden = true;


    } else {
      try {
        div_level = output.singleWhere((e) => e.id == 'ldiv_${p.level}');
        div_level.query('#pdiv-'+p.id) == null ? {} : div_level.query('#pdiv-'+p.id).remove();
      } catch(e) {
        print('Error: $e');
      }

    }
  }
  void drawUpdate(People p){
    try {
      p.firstName = (query('#edit-firstName') as InputElement).value;
      p.lastName = (query('#edit-lastName') as InputElement).value;
      if ( (query('#edit-gender-m') as RadioButtonInputElement).checked == true ) {
        p.gender = 'M';
      } else if ((query('#edit-gender-f') as RadioButtonInputElement).checked == true) {
        p.gender = 'F';
      } else if ((query('#edit-gender-o')as RadioButtonInputElement).checked == true) {
        p.gender = 'O';
      }
    } finally {
      draw(p);
    }
  }
  void drawPC(People p){
    for (People x in p.parents) {
      drawPC(x);
      draw(x);
    }
    draw(p);
    for (People x in p.spouse) {
      draw(x);
      drawPC(x);
    }
    for (People x in p.children) {
      draw(x);
      drawPC(x);
    }
  }
  void drawAll(){
    queryAll('.ldiv').forEach((div) => div.remove());
    drawPC(this);
    output.sort((a,b) => int.parse(a.$dom_getAttribute('lv')) - int.parse(b.$dom_getAttribute('lv')));
    for (DivElement ldiv in output) {
      canvas.append(ldiv);
    }
    queryAll('.general').forEach((e)=> e.style.fontSize=fontSize);
    cvs2d.width = cvs.clientWidth;
    log('${cvs.clientWidth}');
    cvs2d.height = cvs.clientHeight;
    drawAllLines(this);
    if (query("#saveLink") != null) {
      query("#saveLink").remove();
    }
  }
  void drawAllLines(People p){
    for (People x in p.parents) {
      drawAllLines(x);
      drawLine(p, x);
    }
    for (People x in p.spouse) {
      drawLine(p, x);
      drawAllLines(x);
    }
    for (People x in p.children) {
      drawLine(p, x);
      drawAllLines(x);
    }
  }
  void drawLine(People OP, People ED){
    if (!OP.hide && !ED.hide) {
      Rect posOP = canvas.query('#pdiv-'+OP.id).offset;
      Rect posED = canvas.query('#pdiv-'+ED.id).offset;

      int ox = (posOP.left + posOP.width/2).round();
      int oy = (posOP.top + posOP.height/2).round();
      int ex = (posED.left + posED.width/2).round();
      int ey = (posED.top + posED.height/2).round();

      String lineStyle = '#000000';


      if (OP.parents.contains(ED)) {
        lineStyle = '#0000ff';
      } else if (OP.children.contains(ED)) {
        lineStyle = '#00ff00';
      } else if (OP.spouse.contains(ED)) {
        lineStyle = '#ff0000';
      }

      context..beginPath()
             ..lineWidth = 2
             ..strokeStyle = lineStyle
             ..moveTo(ox,oy)
             ..lineTo(ox,(oy + ey)/2)
             ..moveTo(ox,(oy + ey)/2)
             ..lineTo(ex,(oy + ey)/2)
             ..moveTo(ex,(oy + ey)/2)
             ..lineTo(ex,ey)
             ..closePath()
             ..stroke();
    }
  }

  void clearCanvas(){
//    context.clearRect(0, 0, (query("#canvas") as CanvasElement).width, (query("#canvas") as CanvasElement).height);
  }

  void addParentViaButton(People p, String fn, String ln, String g){
    People newParent = new People(id: '${gid++}', firstName: fn, lastName: ln, gender: g);
    p.addParent(newParent);
    log('Added: ${newParent.id}\n');
    clearCanvas();
    this.drawAll();

  }

  void addChildViaButton(People p, String fn, String ln, String g){
    People newChild = new People(id: '${gid++}', firstName: fn, lastName: ln, gender: g);
    p.addChild(newChild);
    log('Added: ${newChild.id}\n');
    clearCanvas();
    this.drawAll();
  }

  void addSpouseViaButton(People p, String fn, String ln, String g){
    People newSpouse= new People(id: '${gid++}', firstName: fn, lastName: ln, gender: g);
    p.addSpouse(newSpouse);
    log('Added: ${newSpouse.id}\n');
    clearCanvas();
    this.drawAll();
  }

  void deleteViaButton(People p){
    if (p.checkRemovable() == true && p != people[0]) {
      log('Removed: ${p.id}\n');
      p.hide = true;
      clearCanvas();
      this.drawAll();
    } else {
      log('Not removable: ${p.id}\n');
    }
  }
  bool checkRemovable(){
      for (People x in this.parents) {
        if (x.hide == false) {
          return false;
        }
      }
      for (People x in this.children) {
        if (x.hide == false) {
          return false;
        }
      }
      for (People x in this.spouse) {
        if (x.hide == false) {
          return false;
        }
      }
      return true;
  }

}

String exportJson(People p){
  return JSON.stringify(toJsonObject(p));
}
JsonObject toJsonObject(People p){
  if (p.hide != true ){
    JsonObject pJO = new JsonObject();

    pJO.isExtendable = true;

  pJO.id = p.id;
  pJO.firstName = p.firstName;
  pJO.lastName = p.lastName;
  pJO.gender = p.gender;
  pJO.level = p.level;
  pJO.parents = new List();
  pJO.children = new List();
  pJO.spouse = new List();

  for (People x in p.parents) {
    toJsonObject(x) == null ? {} : pJO.parents.add(toJsonObject(x));
  }
  for (People x in p.children) {
    toJsonObject(x) == null ? {} : pJO.children.add(toJsonObject(x));
  }
  for (People x in p.spouse) {
    toJsonObject(x) == null ? {} : pJO.spouse.add(toJsonObject(x));
  }

  return pJO;
  } else {
    return null;
  }

}

People getPeopleFromJsonString(String jsonString){
  Map mapJ = JSON.parse(jsonString);
  People p = new People();
  p.id = mapJ['id'];
  gid <= int.parse(mapJ['id']) ? gid+=2 : {};
  p.firstName = mapJ['firstName'];
  p.lastName = mapJ['lastName'];
  p.gender = mapJ['gender'];
  p.level= mapJ['level'];
  for (var x in mapJ['parents']) {
    p.parents.add(getPeopleFromJsonString(JSON.stringify(x)));
  }
  for (var x in mapJ['children']) {
    p.children.add(getPeopleFromJsonString(JSON.stringify(x)));
  }
  for (var x in mapJ['spouse']) {
    p.spouse.add(getPeopleFromJsonString(JSON.stringify(x)));
  }
  return p;
}
const MIME_TYPE = 'text/plain';

void saveData() {
//  log('saving: ${exportJson(people[0])}');
  String jsonData = exportJson(people[0]); // etc...

  var bb = new Blob([jsonData], MIME_TYPE);
//  Blob., type: MIME_TYPE
  if (query("#saveLink") == null) {
  var a = new AnchorElement()
    ..id = 'saveLink';
  a.download = 'MyAncestry.json';
  a.href = Url.createObjectUrl(bb);
  a.text= 'Click to Save (as .json)';
  query("#save-overlay").append(a);}
  else {
    (query("#saveLink") as AnchorElement).href = Url.createObjectUrl(bb);
  }
}

void loadData() {
  log('load');

  FileUploadInputElement uploadInput = query("#loadFile")
    ..hidden = false;
  uploadInput.onChange.listen((e) {
    // read file content as dataURL
    final files = uploadInput.files;
    if (files.length == 1) {
      final file = files[0];
      final reader = new FileReader();
      reader.onLoad.listen((e) {
        sendDatas(reader.result);
      });
      reader.readAsText(file);
    }
  });
}

// send data to server
sendDatas(dynamic data) {
  final req = new HttpRequest();
  req.onReadyStateChange.listen((Event e) {
    if (req.readyState == HttpRequest.DONE &&
        (req.status == 200 || req.status == 0)) {
      onDataLoaded(req.responseText);
    }
  });
  req.open("POST", fileOperationURL);
  req.send(data);
}

// print the raw json response text from the server
void onDataLoaded(String responseText) {
  var jsonString = responseText;
  log('loaded: $jsonString');
  output.clear();
  try {
    People loadedPeople = getPeopleFromJsonString(jsonString);
    people.removeLast();
    people.add(loadedPeople);
    people[0].drawAll();
  } catch (e) {
    window.alert('Wrong file format: $e');
    return null;
  } finally {
    query("#loadFile").hidden = true;
  }

}

void log(String text){
  query('#log').appendText(text);
}
