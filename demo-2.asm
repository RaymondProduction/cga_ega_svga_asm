; rectangle.asm
.model small
.stack 100h

; Оголошення зовнішніх процедур, які визначаються в іншому файлі
extrn set_graphic_mode:proc   ; Процедура встановлення графічного режиму
extrn set_text_mode:proc      ; Процедура повернення до текстового режиму
extrn draw_rectangle:proc     ; Процедура малювання прямокутника
extrn draw_pixel:proc         ; Процедура малювання пікселя

.data
    ; Оголошення кольорів
    black     dw        0
    blue      dw        1
    green     dw        2
    cyan      dw        3
    red       dw        4
    magenta   dw        5
    yellow    dw        6
    gray      dw        7
    dark_gray dw        8

    color     dw        0             ; Початковий колір
    mode      db        0             ; Початковий графічний режим

    ; Дані для шрифтів (графічне представлення символів)
              font_data label byte
    ; A
              db        00011000b
              db        00100100b
              db        01000010b
              db        01111110b
              db        01000010b
              db        01000010b
              db        01000010b
              db        00000000b
    ; B
              db        01111100b
              db        01000010b
              db        01000010b
              db        01111100b
              db        01000010b
              db        01000010b
              db        01111100b
              db        00000000b
    ; C
              db        00111100b
              db        01000010b
              db        01000000b
              db        01000000b
              db        01000000b
              db        01000010b
              db        00111100b
              db        00000000b
    ; ... (додайте дані для інших символів)

.code
    ; Явно вказуємо, що font_data доступний з сегмента коду
                    public font_data

    start:          
                    mov    ax, @data
                    mov    ds, ax                  ; Встановлюємо сегмент даних

    cycle_modes:    
    ; Встановлення графічного режиму
                    mov    al, [mode]              ; Завантажуємо номер режиму
                    call   set_graphic_mode

    ; Малювання кількох прямокутників з різними кольорами
                    mov    cx, 0                   ; Початкова X координата
                    mov    ax, [color]             ; Колір пікселя (спочатку чорний)
    cycle_rectangle:
                    add    cx, 10                  ; Зміщуємо X координату на 10
                    mov    dx, 10                  ; Початкова Y координата
                    mov    bx, 10                  ; Ширина прямокутника
                    mov    si, 10                  ; Висота прямокутника
                    call   draw_rectangle          ; Викликаємо процедуру малювання прямокутника
                    inc    ax                      ; Змінюємо колір пікселя
                    cmp    ax, 16                  ; Перевіряємо чи перевищили максимальне значення
                    jl     cycle_rectangle         ; Повертаємося до циклу, якщо колір менший за 16

    ; Виведення інформації про поточний режим
                    mov    ah, 02h                 ; Функція виведення символу через int 21h
                    mov    dl, '0'                 ; Символ '0'
                    add    dl, [mode]              ; Додаємо номер режиму (0, 1 або 2)
                    int    21h                     ; Виводимо символ на екран

                    mov    al, 'B'                 ; Символ для виведення ('B')
                    mov    cx, 10                  ; X координата для символу
                    mov    dx, 150                 ; Y координата для символу
                    mov    bl, 15                  ; Колір символу (білий)
                    call   draw_char               ; Викликаємо процедуру малювання символу

    ; Очікування натискання клавіші користувачем
                    mov    ah, 0
                    int    16h

    ; Перехід до наступного графічного режиму
                    inc    [mode]
                    cmp    [mode], 3               ; Переходимо до наступного режиму, перевіряємо межу (3)
                    jl     cycle_modes             ; Повертаємося до початку циклу, якщо режим менший за 3

    ; Повернення до текстового режиму
                    call   set_text_mode

    ; Завершення програми
                    mov    ax, 4C00h
                    int    21h

    ; draw_char - процедура для малювання символу на екрані
    ; Вхідні дані:
    ;   AL - ASCII код символу
    ;   CX - X координата
    ;   DX - Y координата
    ;   BL - колір символу
    ; Використовує: AX, BX, CX, DX, SI, DI
draw_char proc
                    push   ax
                    push   bx
                    push   cx
                    push   dx
                    push   si
                    push   di

    ; Отримуємо адресу шрифту для символу
                    sub    al, 'A'                 ; Вираховуємо індекс символу в таблиці шрифтів
                    mov    ah, 0
                    shl    ax, 3                   ; Кожен символ займає 8 байт
                    mov    si, offset font_data    ; Адреса таблиці шрифтів
                    add    si, ax                  ; Додаємо зміщення для конкретного символу

                    mov    di, 8                   ; Висота символу (8 рядків)

    draw_char_loop: 
                    push   cx
                    mov    al, [si]                ; Отримуємо бітовий рядок символу
                    mov    ah, 8                   ; 8 біт на кожний рядок

    draw_char_row:  
                    test   al, 10000000b           ; Перевіряємо, чи встановлений біт
                    jz     draw_char_skip
    
                    push   ax
                    mov    al, bl                  ; Встановлюємо колір пікселя
                    call   draw_pixel              ; Малюємо піксель
                    pop    ax

    draw_char_skip: 
                    inc    cx                      ; Переміщуємо X координату вправо
                    shl    al, 1                   ; Зсуваємо біт для наступного пікселя
                    dec    ah                      ; Зменшуємо кількість бітів
                    jnz    draw_char_row           ; Повторюємо цикл, поки не обробимо всі біти

                    pop    cx
                    inc    dx                      ; Зсуваємо Y координату вниз
                    inc    si                      ; Переходимо до наступного рядка символу
                    dec    di                      ; Зменшуємо лічильник рядків
                    jnz    draw_char_loop          ; Повторюємо цикл для кожного рядка

                    pop    di
                    pop    si
                    pop    dx
                    pop    cx
                    pop    bx
                    pop    ax
                    ret                            ; Повернення з процедури
draw_char endp

end start