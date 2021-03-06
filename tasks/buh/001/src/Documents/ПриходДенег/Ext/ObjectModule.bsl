﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	Запрос = Новый Запрос();
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПриходДенегСостав.Контрагент,
		|	ПриходДенегСостав.ДоговорКонтрагента,
		|	СУММА(ПриходДенегСостав.Сумма) КАК Сумма
		|ПОМЕСТИТЬ втДанныеДокумента
		|ИЗ
		|	Документ.ПриходДенег.Состав КАК ПриходДенегСостав
		|ГДЕ
		|	ПриходДенегСостав.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ПриходДенегСостав.Контрагент,
		|	ПриходДенегСостав.ДоговорКонтрагента
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втДанныеДокумента.Контрагент,
		|	втДанныеДокумента.ДоговорКонтрагента,
		|	втДанныеДокумента.Сумма
		|ИЗ
		|	втДанныеДокумента КАК втДанныеДокумента";

	Запрос.УстановитьПараметр("Ссылка", Ссылка);

	// регистр Управленческий 
	Движения.Управленческий.Записывать = Истина;
	Движения.Управленческий.БлокироватьДляИзменения = Истина;
	Движения.Управленческий.Очистить();

	ДанныеДокумента = Запрос.Выполнить().Выгрузить();

	ПланыСчетовКасса = ПланыСчетов.Управленческий.Касса;
	ПланыСчетовПокупатели = ПланыСчетов.Управленческий.Покупатели;
	ВидыСубконтоКонтрагент = ПланыВидовХарактеристик.ВидыСубконто.Контрагент;
	ВидыСубконтоДоговорКонтрагента = ПланыВидовХарактеристик.ВидыСубконто.ДоговорКонтрагента;

	Для Каждого СтрДанныеДокумента Из ДанныеДокумента Цикл
		Движение = Движения.Управленческий.Добавить();
		Движение.СчетДт = ПланыСчетовКасса;
		Движение.СчетКт = ПланыСчетовПокупатели;
		Движение.Период = Дата;
		Движение.Сумма = СтрДанныеДокумента.Сумма;
		Движение.СубконтоКт[ВидыСубконтоКонтрагент] = СтрДанныеДокумента.Контрагент;
		Движение.СубконтоКт[ВидыСубконтоДоговорКонтрагента] = СтрДанныеДокумента.ДоговорКонтрагента;
	КонецЦикла;

	Движения.Записать();

	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПРЕДСТАВЛЕНИЕ(УправленческийОстатки.Субконто1) КАК КонтрагентПредставление,
		|	ПРЕДСТАВЛЕНИЕ(УправленческийОстатки.Субконто2) КАК ДоговорПредставление,
		|	-УправленческийОстатки.СуммаОстаток КАК Остаток
		|ИЗ
		|	РегистрБухгалтерии.Управленческий.Остатки(
		|			&МоментВремени,
		|			Счет = &Счет,
		|			,
		|			(Субконто1, Субконто2) В
		|				(ВЫБРАТЬ
		|					втДанныеДокумента.Контрагент,
		|					втДанныеДокумента.ДоговорКонтрагента
		|				ИЗ
		|					втДанныеДокумента КАК втДанныеДокумента)) КАК УправленческийОстатки
		|ГДЕ
		|	УправленческийОстатки.СуммаОстаток < 0";

	Запрос.УстановитьПараметр("Счет", ПланыСчетовПокупатели);
	Запрос.УстановитьПараметр("МоментВремени", ?(Режим = РежимПроведенияДокумента.Оперативный, Неопределено, Новый Граница(МоментВремени(), ВидГраницы.Включая)));

	РезультатЗапроса = Запрос.Выполнить();
	Если Не РезультатЗапроса.Пустой() Тогда
		Отказ = Истина;

		Выборка = РезультатЗапроса.Выбрать();
		Пока Выборка.Следующий() Цикл
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Сумма оплаты по договору " + Выборка.ДоговорПредставление + " контрагента " + Выборка.КонтрагентПредставление + " превышает сумму задолженности на " + Строка(Выборка.Остаток);
			Сообщение.Сообщить(); 
		КонецЦикла; 
	КонецЕсли; 
КонецПроцедуры
