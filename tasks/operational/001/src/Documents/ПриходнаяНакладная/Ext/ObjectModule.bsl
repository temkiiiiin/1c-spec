﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход) КАК ВидДвижения,
		|	&Период,
		|	ПриходнаяНакладнаяСписокНоменклатуры.Ссылка КАК Партия,
		|	ПриходнаяНакладнаяСписокНоменклатуры.Номенклатура,
		|	СУММА(ПриходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
		|	СУММА(ПриходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Стоимость
		|ИЗ
		|	Документ.ПриходнаяНакладная.СписокНоменклатуры КАК ПриходнаяНакладнаяСписокНоменклатуры
		|ГДЕ
		|	ПриходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
		|	И НЕ ПриходнаяНакладнаяСписокНоменклатуры.Номенклатура.ВидНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ВидыНоменклатуры.Услуга)
		|
		|СГРУППИРОВАТЬ ПО
		|	ПриходнаяНакладнаяСписокНоменклатуры.Номенклатура,
		|	ПриходнаяНакладнаяСписокНоменклатуры.Ссылка";

	Запрос.УстановитьПараметр("Период", Дата);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);

	Выборка = Запрос.Выполнить().Выбрать();

	Пока Выборка.Следующий() Цикл
		Движение = Движения.ОстаткиНоменклатуры.Добавить();
		Движение.ВидДвижения = Выборка.ВидДвижения;
		Движение.Период = Выборка.Период;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.Партия = Выборка.Партия;
		Движение.Количество = Выборка.Количество;
		Движение.Стоимость = Выборка.Стоимость;
	КонецЦикла;

	Движения.ОстаткиНоменклатуры.Записывать = Истина;
КонецПроцедуры
