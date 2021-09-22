const divisionBigInt = (number1, number2) => {
    return Math.floor(Number(Number(number1) / Number(number2)))
}

const multipBigInt = (number1, number2) => {
    return Math.floor(Number(Number(number1) * Number(number2)))
}

const diffArray = (a, b) => {
    let aSet = new Set(a)
    let bSet = new Set(b)
    return Array.from(new Set(a.concat(b).filter(v => !aSet.has(v) || !bSet.has(v))))
}

export { divisionBigInt, multipBigInt, diffArray }