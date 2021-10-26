<template>
  <div class="bottom">
    <div class="intro">
      <div>
        <h3>Docs</h3>
        <p>Guide</p>
        <p>Advanced</p>
      </div>
      <div>
        <h3>Docs</h3>
        <p>Guide</p>
        <p>Advanced</p>
      </div>
      <div>
        <h3>Docs</h3>
        <p>Guide</p>
        <p>Advanced</p>
      </div>
    </div>
    <div class="copyright">
      <p>© Nnsdao Labs 2021</p>
      <div>
        <span>A</span>
        <span>B</span>
        <span>C</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.bottom {
  border-top: 1px solid #c5a86f;
  width: 100vw;
  height: 186px;
  display: flex;
  flex-direction: column;
  background: #13171a;
  color: #98a7b1;
  padding: 0 16.66vw;
}

.intro {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  font-weight: 400;
  line-height: 30px;
  padding: 30px 2.18vw 12px;
  border-bottom: 1px dashed #2d3b45;
}

.intro p {
  margin: 0;
}

.intro h3 {
  color: #98a7b1;
}

.copyright {
  display: flex;
  justify-content: space-between;
  padding: 12px 2.18vw;
}

.copyright > p{
    margin: 0;
}
</style>