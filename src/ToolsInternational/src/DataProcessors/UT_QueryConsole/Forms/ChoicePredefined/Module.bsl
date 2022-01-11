
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	КопироватьДанныеФормы(Параметры.Объект, Объект);
	ДанныеФормы = Параметры.ДанныеФормы;
	Картинки = ПолучитьИзВременногоХранилища(Объект.Pictures);
	
	ТипЗначения = Неопределено;
	Если ЗначениеЗаполнено(Параметры.ТекстЗапроса) Тогда
		
		ИмяФиктивногоПараметры = "Врп31415926";
		
		Запрос = Новый Запрос(Параметры.ТекстЗапроса);
		
		ТекстЗапроса = Новый ТекстовыйДокумент;
		ТекстЗапроса.УстановитьТекст(Запрос.Текст);
		
		НачальнаяСтрока = ТекстЗапроса.ПолучитьСтроку(Параметры.НачальнаяСтрока);
		КонечнаяСтрока = ТекстЗапроса.ПолучитьСтроку(Параметры.НачальнаяСтрока);
		СтрокаФиктивногоПараметра = Лев(НачальнаяСтрока, Параметры.НачальнаяКолонка - 1) + "&" + ИмяФиктивногоПараметры + Прав(КонечнаяСтрока, СтрДлина(КонечнаяСтрока) - Параметры.КонечнаяКолонка);
		
		ТекстЗапроса.ЗаменитьСтроку(Параметры.НачальнаяСтрока, СтрокаФиктивногоПараметра);
		Для й = Параметры.НачальнаяСтрока + 1 По Параметры.КонечнаяСтрока Цикл
			ТекстЗапроса.УдалитьСтроку(Параметры.НачальнаяСтрока + 1);
		КонецЦикла;
		
		Запрос.Текст = ТекстЗапроса.ПолучитьТекст();
		
		Попытка
			КоллекцияПараметров = Запрос.НайтиПараметры();
			ТипЗначения = КоллекцияПараметров[ИмяФиктивногоПараметры].ТипЗначения;
		Исключение
			//Сообщить("Отладка: " + ОписаниеОшибки());
		КонецПопытки;
		
	КонецЕсли;
	
	сзСписокТипов = Элементы.ТипОбъекта.СписокВыбора;
	сзСписокТипов.Добавить("ВидДвиженияНакопления", "ВидДвиженияНакопления", , Картинки.Тип_ВидДвиженияНакопления);      
	сзСписокТипов.Добавить("ВидДвиженияБухгалтерии", "ВидДвиженияБухгалтерии", , Картинки.Тип_ВидДвиженияНакопления);      
	сзСписокТипов.Добавить("ВидСчета", "ВидСчета", , Картинки.Тип_ВидСчета);
	сзСписокТипов.Добавить("Справочники", "Справочник", , Картинки.Тип_СправочникСсылка);
	сзСписокТипов.Добавить("Документы", "Документ", , Картинки.Тип_ДокументСсылка);
	сзСписокТипов.Добавить("Перечисления", "Перечисление", , Картинки.Тип_ПеречислениеСсылка);
	сзСписокТипов.Добавить("ПланыВидовХарактеристик", "План видов характеристик", , Картинки.Тип_ПланВидовХарактеристикСсылка);
	сзСписокТипов.Добавить("ПланыСчетов", "План счетов", , Картинки.Тип_ПланСчетовСсылка);
	сзСписокТипов.Добавить("ПланыВидовРасчета", "План видов расчета", , Картинки.Тип_ПланВидовРасчетаСсылка);
	сзСписокТипов.Добавить("ПланыОбмена", "План обмена", , Картинки.Тип_ПланОбменаСсылка);
	сзСписокТипов.Добавить("БизнесПроцессы", "Бизнес процесс", , Картинки.Тип_БизнесПроцессСсылка);
	сзСписокТипов.Добавить("Задачи", "Задача", , Картинки.Тип_ЗадачаСсылка);
	
	Если ТипЗначения <> Неопределено Тогда
		
		маТипы = ТипЗначения.Типы();
		
		Если маТипы.Количество() <> 1 Тогда
			ТипЗначения = Неопределено;
		Иначе
			
			Тип = маТипы[0];
			
			Для Каждого эсз Из сзСписокТипов Цикл
				
				Если ТипОбъектаСистемноеПеречисление(эсз.Значение) Тогда
					Если Тип = Тип(эсз.Значение) Тогда
						ТипОбъекта = эсз.Значение;
						ТипОбъектаПриИзмененииНаСервере();
						Прервать;
					КонецЕсли;
					Продолжить;
				КонецЕсли;
					
				Если Вычислить(эсз.Значение).ТипВсеСсылки().СодержитТип(Тип) Тогда
					ТипОбъекта = эсз.Значение;
					ТипОбъектаПриИзмененииНаСервере();
					ИмяОбъекта = ТипЗначения.ПривестиЗначение().Метаданные().Имя;                         
					ИмяОбъектаПриИзмененииНаСервере();
					Прервать;
				КонецЕсли;
				
			КонецЦикла;
		
		КонецЕсли;
		
	КонецЕсли;
		
	Если ТипЗначения = Неопределено И ЗначениеЗаполнено(ДанныеФормы) Тогда
		стДанныеФормы = ПолучитьИзВременногоХранилища(ДанныеФормы);
		ТипОбъекта = стДанныеФормы.ТипОбъекта;
		ТипОбъектаПриИзмененииНаСервере();
		ИмяОбъекта = стДанныеФормы.ИмяОбъекта;
		ИмяОбъектаПриИзмененииНаСервере();
		Элемент = стДанныеФормы.Элемент;
	КонецЕсли;
	
	УстановитьДоступностьКнопок();	
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если НЕ ЗначениеЗаполнено(ДанныеФормы) Тогда
		ДанныеФормы = ЭтаФорма.ВладелецФормы.УникальныйИдентификатор;
	КонецЕсли;
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ТипОбъектаСистемноеПеречисление(ТипОбъекта)
	Возврат ТипОбъекта = "ВидДвиженияНакопления"
		ИЛИ ТипОбъекта = "ВидДвиженияБухгалтерии"
		ИЛИ ТипОбъекта = "ВидСчета";
КонецФункции

&НаСервере
Процедура УстановитьДоступностьКнопок()
	
	Если ТипОбъектаСистемноеПеречисление(ТипОбъекта) Тогда
		Элементы.КомандаВставитьССЫЛКА.Доступность = Ложь;
		Элементы.КомандаВставитьИмя.Доступность = Истина;
		Элементы.КомандаВставитьЗНАЧЕНИЕ.Доступность = Истина;
		Элементы.КомандаВставитьПустаяСсылка.Доступность = Ложь;
	Иначе
		Элементы.КомандаВставитьССЫЛКА.Доступность = ЗначениеЗаполнено(ИмяОбъекта);
		Элементы.КомандаВставитьИмя.Доступность = ЗначениеЗаполнено(Элемент);
		Элементы.КомандаВставитьЗНАЧЕНИЕ.Доступность = Элементы.КомандаВставитьИмя.Доступность;
		Элементы.КомандаВставитьПустаяСсылка.Доступность = Элементы.КомандаВставитьССЫЛКА.Доступность;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ТипОбъектаПриИзмененииНаСервере()

	сзСписокОбъектов = Элементы.ИмяОбъекта.СписокВыбора;
	сзСписокОбъектов.Очистить();
	
	Если ТипОбъекта = "ВидДвиженияНакопления" Тогда
		сзСписокОбъектов.Добавить(ВидДвиженияНакопления.Приход, "Приход");
		сзСписокОбъектов.Добавить(ВидДвиженияНакопления.Расход, "Расход");
		Элементы.ИмяОбъекта.ОграничениеТипа = Новый ОписаниеТипов("ВидДвиженияНакопления");
		ИмяОбъекта = ВидДвиженияНакопления.Приход;
	ИначеЕсли ТипОбъекта = "ВидДвиженияБухгалтерии" Тогда
		сзСписокОбъектов.Добавить(ВидДвиженияБухгалтерии.Дебет, "Дебет");
		сзСписокОбъектов.Добавить(ВидДвиженияБухгалтерии.Кредит, "Кредит");
		Элементы.ИмяОбъекта.ОграничениеТипа = Новый ОписаниеТипов("ВидДвиженияБухгалтерии");
		ИмяОбъекта = ВидДвиженияБухгалтерии.Дебет;
	ИначеЕсли ТипОбъекта = "ВидСчета" Тогда
		сзСписокОбъектов.Добавить(ВидСчета.АктивноПассивный, "Активный");
		сзСписокОбъектов.Добавить(ВидСчета.Активный, "Активный");
		сзСписокОбъектов.Добавить(ВидСчета.Пассивный, "Пассивный");
		Элементы.ИмяОбъекта.ОграничениеТипа = Новый ОписаниеТипов("ВидСчета");
		ИмяОбъекта = ВидСчета.АктивноПассивный;
	Иначе
		
		МетаданныеТипа = Метаданные[ТипОбъекта];
		Для Каждого мдОбъект Из МетаданныеТипа Цикл
			сзСписокОбъектов.Добавить(мдОбъект.Имя);
		КонецЦикла;
		
		Элементы.ИмяОбъекта.ОграничениеТипа = Новый ОписаниеТипов("Строка");
		ИмяОбъекта = "";
		
	КонецЕсли;
	
	Элементы.ИмяОбъекта.Доступность = Истина;
	ИмяОбъектаПриИзмененииНаСервере();
	УстановитьДоступностьКнопок();	
		
КонецПроцедуры

&НаКлиенте
Процедура ТипОбъектаПриИзменении(Элемент)
	ТипОбъектаПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура ИмяОбъектаПриИзмененииНаСервере()

	Если ТипЗнч(ИмяОбъекта) <> Тип("Строка") Тогда
		Элемент = Неопределено;
		Элементы.Элемент.Доступность = Ложь;
		Возврат;
	КонецЕсли;
	
	сзСписокОбъектов = Элементы.Элемент.СписокВыбора;
	сзСписокОбъектов.Очистить();
	
	Если ЗначениеЗаполнено(ИмяОбъекта) Тогда
		
		Если ТипОбъекта = "Справочники" Тогда
			зЗапрос = Новый Запрос(СтрШаблон("ВЫБРАТЬ Ссылка ИЗ Справочник.%1 ГДЕ Предопределенный", ИмяОбъекта));
			маЭлементы = зЗапрос.Выполнить().Выгрузить().ВыгрузитьКолонку(0);
			сзСписокОбъектов.ЗагрузитьЗначения(маЭлементы);
		ИначеЕсли ТипОбъекта = "ПланыВидовХарактеристик" Тогда
			зЗапрос = Новый Запрос(СтрШаблон("ВЫБРАТЬ Ссылка ИЗ ПланВидовХарактеристик.%1 ГДЕ Предопределенный", ИмяОбъекта));
			маЭлементы = зЗапрос.Выполнить().Выгрузить().ВыгрузитьКолонку(0);
			сзСписокОбъектов.ЗагрузитьЗначения(маЭлементы);
		ИначеЕсли ТипОбъекта = "Перечисления" Тогда
			зЗапрос = Новый Запрос(СтрШаблон("ВЫБРАТЬ Ссылка ИЗ Перечисление.%1", ИмяОбъекта));
			маЭлементы = зЗапрос.Выполнить().Выгрузить().ВыгрузитьКолонку(0);
			сзСписокОбъектов.ЗагрузитьЗначения(маЭлементы);
		ИначеЕсли ТипОбъекта = "ПланыСчетов" Тогда
			зЗапрос = Новый Запрос(СтрШаблон("ВЫБРАТЬ Ссылка ИЗ ПланСчетов.%1 ГДЕ Предопределенный", ИмяОбъекта));
			маЭлементы = зЗапрос.Выполнить().Выгрузить().ВыгрузитьКолонку(0);
			сзСписокОбъектов.ЗагрузитьЗначения(маЭлементы);
		ИначеЕсли ТипОбъекта = "ПланыВидовРасчета" Тогда
			зЗапрос = Новый Запрос(СтрШаблон("ВЫБРАТЬ Ссылка ИЗ ПланВидовРасчета.%1 ГДЕ Предопределенный", ИмяОбъекта));
			маЭлементы = зЗапрос.Выполнить().Выгрузить().ВыгрузитьКолонку(0);
			сзСписокОбъектов.ЗагрузитьЗначения(маЭлементы);
		КонецЕсли;
		
	КонецЕсли;
	
	Элемент = Неопределено;
	
	Элементы.Элемент.Доступность = НЕ (
		ТипОбъектаСистемноеПеречисление(ТипОбъекта)
		ИЛИ ТипОбъекта = "ПланыОбмена"
		ИЛИ ТипОбъекта = "БизнесПроцессы"
		ИЛИ ТипОбъекта = "Задачи");

	УстановитьДоступностьКнопок();	
		
КонецПроцедуры

&НаКлиенте
Процедура ИмяОбъектаПриИзменении(Элемент)
	ИмяОбъектаПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура СохранитьДанныеФормы()
	стДанныеФормы = Новый Структура("ТипОбъекта, ИмяОбъекта, Элемент", ТипОбъекта, ИмяОбъекта, Элемент);
	ДанныеФормы = ПоместитьВоВременноеХранилище(стДанныеФормы, ДанныеФормы);
КонецПроцедуры

&НаКлиенте
Процедура ЭлементПриИзменении(Элемент)
	УстановитьДоступностьКнопок();	
КонецПроцедуры

&НаСервере
Функция ТипДляЗапроса(НазваниеТипаВМетаданных)
	Если НазваниеТипаВМетаданных = "Справочники" Тогда Возврат "Справочник";
	ИначеЕсли НазваниеТипаВМетаданных = "Перечисления" Тогда Возврат "Перечисление";
	ИначеЕсли НазваниеТипаВМетаданных = "ПланыВидовХарактеристик" Тогда Возврат "ПланВидовХарактеристик";
	ИначеЕсли НазваниеТипаВМетаданных = "ПланыСчетов" Тогда Возврат "ПланСчетов";
	ИначеЕсли НазваниеТипаВМетаданных = "ПланыВидовРасчета" Тогда Возврат "ПланВидовРасчета";
	ИначеЕсли НазваниеТипаВМетаданных = "ПланыОбмена" Тогда Возврат "ПланОбмена";
	ИначеЕсли НазваниеТипаВМетаданных = "БизнесПроцессы" Тогда Возврат "БизнесПроцесс";
	ИначеЕсли НазваниеТипаВМетаданных = "Задачи" Тогда Возврат "Задача";
	ИначеЕсли НазваниеТипаВМетаданных = "Документы" Тогда Возврат "Документ";
	Иначе
		Возврат НазваниеТипаВМетаданных;
	КонецЕсли;
КонецФункции

&НаСервере
Функция ПолучитьЛитералОбъектаДляЗапроса()
	Возврат ТипДляЗапроса(ТипОбъекта) + "." + ИмяОбъекта;
КонецФункции

&НаСервере
Функция ПолучитьЛитералЭлементаДляЗапроса()
	Если ТипОбъектаСистемноеПеречисление(ТипОбъекта) Тогда
		Возврат ПолучитьЛитералОбъектаДляЗапроса();
	Иначе
		Если ТипОбъекта = "Перечисления" Тогда
			МетаданныеПеречисления = Элемент.Метаданные();
			Менеджер = Перечисления[МетаданныеПеречисления.Имя];
			Возврат ПолучитьЛитералОбъектаДляЗапроса() + "." + МетаданныеПеречисления.ЗначенияПеречисления.Получить(Менеджер.Индекс(Элемент)).Имя;
		Иначе			
			Возврат ПолучитьЛитералОбъектаДляЗапроса() + "." + Элемент.ИмяПредопределенныхДанных;
		КонецЕсли;
	КонецЕсли;
КонецФункции

&НаКлиенте
Процедура КомандаВставитьИмя(Команда)
	Закрыть(КомандаВставитьИмяНаСервере());
КонецПроцедуры

&НаКлиенте
Функция КомандаВставитьИмяНаСервере()
	СохранитьДанныеФормы();
	Возврат Новый Структура("ДанныеФормы, Результат", ДанныеФормы, ПолучитьЛитералЭлементаДляЗапроса());
КонецФункции

&НаКлиенте
Процедура КомандаВставитьЗНАЧЕНИЕ(Команда)
	Закрыть(КомандаВставитьЗНАЧЕНИЕНаСервере());
КонецПроцедуры

&НаСервере
Функция КомандаВставитьЗНАЧЕНИЕНаСервере()
	СохранитьДанныеФормы();                                
	Возврат Новый Структура("ДанныеФормы, Результат", ДанныеФормы, "ЗНАЧЕНИЕ(" + ПолучитьЛитералЭлементаДляЗапроса() + ")");
КонецФункции

&НаКлиенте
Процедура КомандаВставитьССЫЛКА(Команда)
	Закрыть(КомандаВставитьССЫЛКАНаСервере());
КонецПроцедуры

&НаСервере
Функция КомандаВставитьССЫЛКАНаСервере()
	СохранитьДанныеФормы();
	Возврат Новый Структура("ДанныеФормы, Результат", ДанныеФормы, "ССЫЛКА " + ПолучитьЛитералОбъектаДляЗапроса());
КонецФункции

&НаКлиенте
Процедура КомандаВставитьПустаяСсылка(Команда)
	Закрыть(КомандаВставитьПустаяСсылкаНаСервере());
КонецПроцедуры

&НаСервере
Функция КомандаВставитьПустаяСсылкаНаСервере()
	СохранитьДанныеФормы();                                
	Возврат Новый Структура("ДанныеФормы, Результат", ДанныеФормы, "ЗНАЧЕНИЕ(" + ПолучитьЛитералОбъектаДляЗапроса() + ".ПустаяСсылка)");
КонецФункции