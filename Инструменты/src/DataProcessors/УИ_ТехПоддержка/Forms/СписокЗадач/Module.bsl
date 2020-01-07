#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОбновитьСписокЗадачНаСервере();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы


&НаКлиенте
Процедура СписокЗадачВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка=Ложь;
	
	ДанныеСтроки=СписокЗадач.НайтиПоИдентификатору(ВыбраннаяСтрока);
	
	ЗапуститьПриложение(ДанныеСтроки.URL);
КонецПроцедуры


#КонецОбласти

#Область ОбработчикиКомандФормы


&НаКлиенте
Процедура ОбновитьСписокЗадач(Команда)
	ОбновитьСписокЗадачНаСервере();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОбновитьСписокЗадачНаСервере()
	СписокЗадач.Очистить();
	
	БазовыйАдрес="https://api.github.com/repos/cpr1c/tools_ui_1c/issues";
	
	СписокЗадачРепозитория=УИ_КоннекторHTTP.GetJson(БазовыйАдрес);
	
	Для Каждого ЗадачаРепозитория ИЗ СписокЗадачРепозитория Цикл
		НоваяЗадача=СписокЗадач.Добавить();
		НоваяЗадача.Номер=ЗадачаРепозитория["number"];	
		НоваяЗадача.URL=ЗадачаРепозитория["html_url"];	
		НоваяЗадача.Тема=ЗадачаРепозитория["title"];
		НоваяЗадача.Статус=ЗадачаРепозитория["state"];
		ОтветственныйЗадача=ЗадачаРепозитория["assignee"];
		Если ТипЗнч(ОтветственныйЗадача)=Тип("Соответствие") Тогда
			НоваяЗадача.Ответственный=ОтветственныйЗадача["login"];
		КонецЕсли;	
		
		ТегиЗадачи=ЗадачаРепозитория["labels"];
		Если ТипЗнч(ТегиЗадачи)=Тип("Массив") Тогда
			Для Каждого ТекущийТег ИЗ ТегиЗадачи Цикл
				НоваяЗадача.Теги.Добавить(ТекущийТег["name"]);
			КонецЦикла;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьНовуюЗадачу(Команда)
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураТела=Новый Структура;
	СтруктураТела.Вставить("title", НоваяЗадачаТема);
	СтруктураТела.Вставить("body", НоваяЗадачаОписание);

	БазовыйАдрес="https://api.github.com/repos/cpr1c/tools_ui_1c/issues";
	
	Результат=УИ_КоннекторHTTP.PostJson(БазовыйАдрес,СтруктураТела);

	ОбновитьСписокЗадачНаСервере();
КонецПроцедуры





#КонецОбласти



